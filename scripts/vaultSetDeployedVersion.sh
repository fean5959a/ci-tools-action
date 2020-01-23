#!/bin/bash

cd "${CI_PROJECT_DIR}" || exit 1

. ./vault-ci-tools/libtools.sh
echoHeader "Vault Set Deployed Version"

VAULT_SECRET_DATA='{"version":"'"${IMAGE_VERSION}"'"}'
export VAULT_SECRET_DATA

while [ $# -gt 0 ]; do
  case $1 in
  --secret-path)
    export VAULT_WRITE_SECRET_PATH="${2}"
    shift
    ;;
  --secret-data)
    export VAULT_SECRET_DATA="${2}"
    shift
    ;;
  esac
  shift
done

if [ -z "${VAULT_WRITE_SECRET_PATH}" ]; then
  echo "[ERROR] No secret path"
  exit 1
fi

echo "Write secret ${VAULT_WRITE_SECRET_PATH}"
curl -H "X-Vault-Token:${VAULT_TOKEN}" -H "X-Vault-Namespace:${VAULT_NAMESPACE}" --request POST --data '{"options":{},"data":'"${VAULT_SECRET_DATA}"'}' "${VAULT_ADDR}/v1/${SECRET_BACKEND}/data/${VAULT_WRITE_SECRET_PATH}"
