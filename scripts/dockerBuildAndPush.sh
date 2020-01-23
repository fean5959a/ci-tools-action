#!/bin/bash

while [ $# -gt 0 ]; do
  case $1 in
  --registry-name)
    export REGISTRY_NAME="${2}"
    shift
    ;;
  --image-name)
    export IMAGE_NAME="${2}"
    shift
    ;;
  --dockerfile-path)
    export DOCKERFILE_PATH="${2}"
    cd "$(dirname ${DOCKERFILE_PATH})" || exit 1
    shift
    ;;
  esac
  shift
done

if [ -z "${DOCKERFILE_PATH}" ]; then
  DOCKERFILE_PATH="."
  export DOCKERFILE_PATH
fi

docker login -u "${JFROG_USER}" -p "${JFROG_TOKEN}" "${REGISTRY_NAME}" || exit 1

docker build -t "${REGISTRY_NAME}/${IMAGE_NAME}" ${DOCKERFILE_PATH} || exit 1

docker push "${REGISTRY_NAME}/${IMAGE_NAME}" || exit 1

docker rmi "${REGISTRY_NAME}/${IMAGE_NAME}" || exit 1
