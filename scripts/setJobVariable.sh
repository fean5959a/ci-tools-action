#!/bin/bash

function setJobVariable {
    echo "${1}=${2}" >> $GITHUB_ENV
}

if [ -z "${IMAGE_NAME}" ]; then
    export IMAGE_TAG="${IMAGE_VERSION}-${BRANCH_NAME}"
    setJobVariable IMAGE_TAG "${IMAGE_TAG}"
fi

if [ -z "${SECRET_PATH}" ]; then
    export SECRET_PATH="${APP_NAME}/${BRANCH_NAME}"
    setJobVariable SECRET_PATH "${SECRET_PATH}"
fi

if [ -z "${ENV_LABEL_NAME}" ]; then
    export ENV_LABEL_NAME="${BRANCH_NAME}"
    if [ "${BRANCH_NAME}" != "master" ] && [ "${BRANCH_NAME}" != "staging" ]; then
        export ENV_LABEL_NAME="dev"
    fi
    setJobVariable ENV_LABEL_NAME "${ENV_LABEL_NAME}"
fi

if [ -z "${OC_APP_VERSION}" ]; then
    OC_APP_VERSION=$(echo "${IMAGE_VERSION}" | sed 's/\./-/g')
    export OC_APP_VERSION
    setJobVariable OC_APP_VERSION "${OC_APP_VERSION}"
fi

if [ -z "${OC_MAIN_SERVICE_VERSION}" ]; then
    OC_MAIN_SERVICE_VERSION=$(echo "${IMAGE_VERSION}" | sed 's/\./-/g')
    export OC_MAIN_SERVICE_VERSION
    setJobVariable OC_MAIN_SERVICE_VERSION "${OC_MAIN_SERVICE_VERSION}"
fi

if [ -z "${OC_NAME}" ]; then
    OC_NAME=$(echo "${APP_NAME}-${OC_APP_VERSION}-${BRANCH_NAME}" | sed 's/--/-/g')
    export OC_NAME
    setJobVariable OC_NAME "${OC_NAME}"
fi

if [ -z "${OC_ROUTE_PREVIEW}" ]; then
    OC_ROUTE_PREVIEW=$(echo "${APP_NAME}-preview" | sed 's/--/-/g')
    export OC_ROUTE_PREVIEW
    setJobVariable OC_ROUTE_PREVIEW "${OC_ROUTE_PREVIEW}"
fi

if [ -z "${OC_ROUTE_NAME}" ]; then
    OC_ROUTE_NAME=$(echo "${APP_NAME}-${OC_APP_VERSION}-${BRANCH_NAME}" | sed 's/--/-/g')
    export OC_ROUTE_NAME
    setJobVariable OC_ROUTE_NAME "${OC_ROUTE_NAME}"
fi

if [ -z "${OC_MAIN_APP_NAME}" ]; then
    OC_MAIN_APP_NAME=$(echo "${APP_NAME}-${BRANCH_NAME}" | sed 's/--/-/g')
    export OC_MAIN_APP_NAME
    setJobVariable OC_MAIN_APP_NAME "${OC_MAIN_APP_NAME}"
fi

if [ -z "${OC_MAIN_ROUTE_NAME}" ]; then
    OC_MAIN_ROUTE_NAME=$(echo "${APP_NAME}"|sed 's/--/-/g')
    export OC_MAIN_ROUTE_NAME
    setJobVariable OC_MAIN_ROUTE_NAME "${OC_MAIN_ROUTE_NAME}"
fi

if [ -z "${OC_MAIN_SERVICE}" ]; then
    if [ "${OC_MAIN_SERVICE_VERSION}" = "None" ]; then
        OC_MAIN_SERVICE="$(echo "${APP_NAME}-${BRANCH_NAME}" | sed 's/--/-/g')"
        export OC_MAIN_SERVICE
    else
        OC_MAIN_SERVICE="$(echo "${APP_NAME}-${OC_MAIN_SERVICE_VERSION}-${BRANCH_NAME}" | sed 's/--/-/g')"
        export OC_MAIN_SERVICE
    fi
    setJobVariable OC_MAIN_SERVICE "${OC_MAIN_SERVICE}"
fi

if [ -z "${OC_ALTERNATE_SERVICE}" ]; then
    OC_ALTERNATE_SERVICE="$(echo "${APP_NAME}-${OC_APP_VERSION}-${BRANCH_NAME}" | sed 's/--/-/g')"
    export OC_ALTERNATE_SERVICE
    setJobVariable OC_ALTERNATE_SERVICE "${OC_ALTERNATE_SERVICE}"
fi

