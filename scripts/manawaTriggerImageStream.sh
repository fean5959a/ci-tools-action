#!/bin/bash

cd "${CI_PROJECT_DIR}" || exit 1

. ./vault-ci-tools/libtools.sh
echoHeader "Manawa Trigger Image Steam"

if [ -z "${OC_NAME}" ]; then
  OC_NAME=$(echo "${APP_NAME}-${CI_COMMIT_REF_NAME}" | sed 's/--/-/g')
fi

if [ -z "${ENV_LABEL_NAME}" ]; then
  export ENV_LABEL_NAME="${CI_COMMIT_REF_NAME}"
  if [ "${CI_COMMIT_REF_NAME}" != "master" ] && [ "${CI_COMMIT_REF_NAME}" != "staging" ]; then
    export ENV_LABEL_NAME="dev"
  fi
fi

sh ./vault-ci-tools/vaultGetSecretKeyToFile.sh -s "${VAULT_SECRET_PATH}" -k "${ENV_LABEL_NAME}" -o /tmp/${ENV_LABEL_NAME}.sh || exit 1
. /tmp/${ENV_LABEL_NAME}.sh

# Trigger image
oc --insecure-skip-tls-verify login --token="${OC_TOKEN}" "${OC_URL}" || exit 1
oc --insecure-skip-tls-verify import-image "${OC_NAME}:${IMAGE_TAG}" --scheduled=true --confirm=true || exit 1
