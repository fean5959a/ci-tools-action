#!/bin/bash

cd "${CI_PROJECT_DIR}" || exit 1

usage() {
  cat <<'EOF'
# manawaDeploy.sh
Delete a Manawa set of objects, identity by OC_NAME.
## Usage

```bash
sh ./vault-ci-tools/manawaDeploy.sh
```

## Environment variables used:
All these environment variable can be used/overwrite.

| Variable Name | Description  |
|----|----|
| ENV_LABEL_NAME | Lable used to determine environment use to retreive Vault secrets for CI pipeline|
| VAULT_SECRET_PATH | CI pipeline Vault secret path used |
| OC_NAME | Name used in Kubernetes yaml file to named objects |
EOF
  exit 1
}

while [ $# -gt 0 ]; do
  case $1 in
  -h|--help)
    usage
    ;;
  esac
  shift
done

. ./vault-ci-tools/libtools.sh
echoHeader "Manawa Remove App"

if [ -z "${OC_NAME}" ]; then
  OC_NAME=$(echo "${APP_NAME}-${CI_COMMIT_REF_NAME}" | sed 's/--/-/g')
  export OC_NAME
fi

if [ -z "${ENV_LABEL_NAME}" ]; then
  export ENV_LABEL_NAME="${CI_COMMIT_REF_NAME}"
  if [ "${CI_COMMIT_REF_NAME}" != "master" ] && [ "${CI_COMMIT_REF_NAME}" != "staging" ]; then
    export ENV_LABEL_NAME="dev"
  fi
fi

sh ./vault-ci-tools/vaultGetSecretKeyToFile.sh -s "${VAULT_SECRET_PATH}" -k "${ENV_LABEL_NAME}" -o /tmp/${ENV_LABEL_NAME}.sh || exit 1
. /tmp/${ENV_LABEL_NAME}.sh

# Reset Manawa
oc --insecure-skip-tls-verify login --token="${OC_TOKEN}" "${OC_URL}" || exit 1
oc --insecure-skip-tls-verify delete all,configmap,pvc --selector app="${OC_NAME}" || exit 1
