#!/bin/bash

export OC_ROUTE_FILE="oc_route.yml"
export OC_ROUTE_DIR="${RUNNER_TEMP}"

if [ -z "${OC_MAIN_SERVICE_WEIGHT}" ]; then
  export OC_MAIN_SERVICE_WEIGHT="100"
fi
if [ -z "${OC_ALTERNATE_SERVICE_WEIGHT}" ]; then
  export OC_ALTERNATE_SERVICE_WEIGHT="0"
fi

while [ $# -gt 0 ]; do
  case $1 in
  --oc-route-file)
    OC_ROUTE_DIR=$(dirname "${2}")
    export OC_ROUTE_DIR
    OC_ROUTE_FILE=$(basename "${2}")
    export OC_ROUTE_FILE
    shift
    ;;
  --oc-route-name)
    export OC_MAIN_APP_NAME="${2}"
    shift
    ;;
  --oc-route-port)
    export OC_API_PORT="${2}"
    shift
    ;;
  --oc-main-service)
    export OC_MAIN_SERVICE="${2}"
    shift
    ;;
  --oc-main-service-weight)
    export OC_MAIN_SERVICE_WEIGHT="${2}"
    shift
    ;;
  --oc-alternate-service)
    export OC_ALTERNATE_SERVICE="${2}"
    shift
    ;;
  --oc-alternate-service-weight)
    export OC_ALTERNATE_SERVICE_WEIGHT="${2}"
    shift
    ;;
  --with-ca)
    export OC_ROUTE_REENCRYPT="true"
    ;;
  --oc-route-no-sticky)
    export OC_ROUTE_NO_STICKY="true"
    ;;
  esac
  shift
done

echo "Build OpenShift route: ${OC_MAIN_ROUTE_NAME}"
echo "  - Add annotations, labels, name and port"
cat << EOF > "${OC_ROUTE_DIR}/${OC_ROUTE_FILE}.tmpl"
apiVersion: route.openshift.io/v1
kind: Route
metadata:
  annotations:
    haproxy.router.openshift.io/balance: roundrobin
EOF

if [ "${OC_ROUTE_NO_STICKY}" = "true" ]; then
  cat << EOF >> "${OC_ROUTE_DIR}/${OC_ROUTE_FILE}.tmpl"
    haproxy.router.openshift.io/disable_cookies: 'true'
EOF
fi

echo "  - OC_MAIN_ROUTE_NAME=$OC_MAIN_ROUTE_NAME"
cat << EOF >> "${OC_ROUTE_DIR}/${OC_ROUTE_FILE}.tmpl"
    haproxy.router.openshift.io/timeout: 900s
    openshift.io/host.generated: 'true'
  labels:
    app: $OC_MAIN_ROUTE_NAME
  name: $OC_MAIN_ROUTE_NAME
spec:
  port:
    targetPort: $OC_API_PORT-tcp
EOF

if [ "${OC_ROUTE_REENCRYPT}" = "true" ]; then
  echo "  - Set reencrypt / redirect"
  cat << EOF >> "${OC_ROUTE_DIR}/${OC_ROUTE_FILE}.tmpl"
  tls:
    destinationCACertificate: |-
      __SERVICE_CA__
    insecureEdgeTerminationPolicy: Redirect
    termination: reencrypt
EOF
else
  echo "  - Set edge / redirect"
  cat << EOF >> "${OC_ROUTE_DIR}/${OC_ROUTE_FILE}.tmpl"
  tls:
    insecureEdgeTerminationPolicy: Redirect
    termination: edge
EOF
fi

echo "  - Set main service: ${OC_MAIN_SERVICE}"
cat << EOF >> "${OC_ROUTE_DIR}/${OC_ROUTE_FILE}.tmpl"
  to:
    kind: Service
    name: $OC_MAIN_SERVICE
EOF

echo "  - OC_ALTERNATE_SERVICE=${OC_ALTERNATE_SERVICE}"
echo "  - Compare >${OC_MAIN_SERVICE}< and >${OC_ALTERNATE_SERVICE}<"
if [ -n "${OC_ALTERNATE_SERVICE}" ] && [ "${OC_MAIN_SERVICE}" != "${OC_ALTERNATE_SERVICE}" ]; then
  echo "  - Set alternate service: ${OC_ALTERNATE_SERVICE}"
  cat << EOF >> "${OC_ROUTE_DIR}/${OC_ROUTE_FILE}.tmpl"
    weight: $OC_MAIN_SERVICE_WEIGHT
  alternateBackends:
    - kind: Service
      name: $OC_ALTERNATE_SERVICE
      weight: $OC_ALTERNATE_SERVICE_WEIGHT
EOF
fi
cat << EOF >> "${OC_ROUTE_DIR}/${OC_ROUTE_FILE}.tmpl"
  wildcardPolicy: None
EOF

bash ${CI_TOOLS_DIR}/manawaDeploy.sh -d "${OC_ROUTE_DIR}" -f "${OC_ROUTE_FILE}"