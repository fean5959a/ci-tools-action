#!/bin/bash

while [ $# -gt 0 ]; do
  case $1 in
  --registry-src)
    export REGISTRY_SRC="${2}"
    shift
    ;;
  --registry-dst)
    export REGISTRY_DST="${2}"
    shift
    ;;
  --image-src)
    export IMAGE_NAME_SRC="${2}"
    shift
    ;;
  --image-dst)
    export IMAGE_NAME_DST="${2}"
    shift
    ;;
  esac
  shift
done

export IMAGE_SRC="${REGISTRY_SRC}/${IMAGE_NAME_SRC}"
export IMAGE_DST="${REGISTRY_DST}/${IMAGE_NAME_DST}"

docker login -u "${JFROG_USER}" -p "${JFROG_TOKEN}" "${REGISTRY_SRC}" || exit 1
docker pull "${IMAGE_SRC}" || exit 1

if [ "${REGISTRY_SRC}" != "${REGISTRY_DST}" ]; then
    docker login -u "${JFROG_USER}" -p "${JFROG_TOKEN}" "${REGISTRY_DST}" || exit 1
fi

docker tag "${IMAGE_SRC}" "${IMAGE_DST}" || exit 1
docker push "${IMAGE_DST}" || exit 1
docker rmi "${IMAGE_DST}" || exit 1

docker rmi "${IMAGE_SRC}" || exit 1
