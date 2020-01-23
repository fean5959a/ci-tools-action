#!/bin/bash

if [ -z "${VAULT_ADDR}" ]; then
  VAULT_ADDR="https://vault.factory.adeo.cloud"
fi

export SECRET_BACKEND="secret"

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
  --vault-namespace)
    export VAULT_NAMESPACE="${2}"
    shift
    ;;
  --secret-backend)
    export SECRET_BACKEND="${2}"
    shift
    ;;
  esac
  shift
done

if [ -z "${VAULT_WRITE_SECRET_PATH}" ]; then
  echo "[ERROR] No write secret path provided"
  exit 1
fi

if [ ! -f vault.token ]; then
  sh ./vault-ci-tools/vaultDecryptToken.sh

  if [ ! -f vault.token ]; then
    echo "[ERROR] No Vault token file."
    exit 1
  fi
fi

VAULT_TOKEN=$(head -n 1 vault.token)
export VAULT_TOKEN

echo "Write secret ${VAULT_WRITE_SECRET_PATH}"
curl -H "X-Vault-Token:${VAULT_TOKEN}" -H "X-Vault-Namespace:${VAULT_NAMESPACE}" --request POST --data '{"options":{},"data":'"${VAULT_SECRET_DATA}"'}' "${VAULT_ADDR}/v1/${SECRET_BACKEND}/data/${VAULT_WRITE_SECRET_PATH}"
