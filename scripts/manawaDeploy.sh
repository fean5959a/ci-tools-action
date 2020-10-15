#!/bin/bash


KUB_FILE_DIR="manawa"
KUB_FILES="kubernetes.yml"

while [ $# -gt 0 ]; do
  case $1 in
  -d)
    export KUB_FILE_DIR="${2}"
    shift
    ;;
  -f)
    export KUB_FILES="${2}"
    shift
    ;;
  esac
  shift
done

OC_CA_FILE=$(mktemp)

${OC_BIN} --insecure-skip-tls-verify login --token="${OC_TOKEN}" "${OC_URL}"
${OC_BIN} --insecure-skip-tls-verify project "${OC_PROJECT}"

CA_SECRET=$(${OC_BIN} --insecure-skip-tls-verify  get secret | grep default-token | head -n 1 | sed 's/[ ][ ].*//')
CA_BASE64=$(${OC_BIN} --insecure-skip-tls-verify  get secret "${CA_SECRET}" -o yaml | grep service-ca.crt | sed 's/.*service-ca.crt: //')
echo "${CA_BASE64}" | base64 -d | awk '{print("      "$0)}' >${OC_CA_FILE}

function process_kub_file {
  _KUB_FILE="${1}"

  echo " - Process file ${KUB_FILE_DIR}/${_KUB_FILE}"

  if [ ! -f "${KUB_FILE_DIR}/${_KUB_FILE}" ] && [ ! -f "${KUB_FILE_DIR}/${_KUB_FILE}.tmpl" ]; then
    echo " - No Kubernetes file (${KUB_FILE_DIR}/${_KUB_FILE})"
    return
  fi

  # Build kubernetes yaml
  echo " - Replace variables"
  envsubst <"${KUB_FILE_DIR}/${_KUB_FILE}.tmpl" >"${KUB_FILE_DIR}/${_KUB_FILE}" || exit 1

  # Deploy to Manawa
  if grep '__SERVICE_CA__' "${KUB_FILE_DIR}/${_KUB_FILE}" 1>/dev/null 2>&1; then
    echo " - Update CA"
    sed '/__SERVICE_CA__/r '${OC_CA_FILE} "${KUB_FILE_DIR}/${_KUB_FILE}" | sed '/__SERVICE_CA__/d' >"${KUB_FILE_DIR}/${_KUB_FILE}.tmp" || exit 1
    mv "${KUB_FILE_DIR}/${_KUB_FILE}.tmp" "${KUB_FILE_DIR}/${_KUB_FILE}" || exit 1
  fi

  echo " - Deploy to Openshift"
  ${OC_BIN} --insecure-skip-tls-verify apply -f "${KUB_FILE_DIR}/${_KUB_FILE}" || exit 1
  echo " - >> Deploy ${KUB_FILE_DIR}/${_KUB_FILE}: done"
  cat ${KUB_FILE_DIR}/${_KUB_FILE}
}

for KUB_FILE in $(echo "${KUB_FILES}" | sed 's/,/ /g'); do
  process_kub_file "${KUB_FILE}"
done

rm "${OC_CA_FILE}"
