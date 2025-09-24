#!/bin/bash
# Copyright (c) Istituto Nazionale di Fisica Nucleare (INFN). 2016-2019
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
set -e

# Check for env file in current dir
if [ -r .env ]; then 
  set -a
  source .env
  set +a 
fi

if [ -n "${DOCKER_VERBOSE}" ]; then
  set -x
fi

if [ -z "${DOCKER_IMAGE}" ]; then
  echo "Please set the DOCKER_IMAGE env variable"
  exit 1
fi

DOCKER_TAG=${DOCKER_TAG:-"latest"}
DOCKER_REGISTRY_NAMESPACE=${DOCKER_REGISTRY_NAMESPACE:-}

if [ -n "${DOCKER_REGISTRY_HOST}" ]; then

  if [ -n "${DOCKER_REGISTRY_NAMESPACE}" ]; then
    IMG_NAME="${DOCKER_REGISTRY_HOST}/${DOCKER_REGISTRY_NAMESPACE}/$(echo ${DOCKER_IMAGE} | cut -d '/' -f2)"
  else 
    IMG_NAME=${DOCKER_REGISTRY_HOST}/${DOCKER_IMAGE}
  fi

  if [ -n "${DOCKER_GIT_TAG_ENABLED}" ]; then

    GIT_COMMIT_SHA=${CI_COMMIT_SHORT_SHA:-$(git rev-parse --short HEAD)}
    GIT_BRANCH_NAME=${CI_COMMIT_REF_SLUG:-$(echo ${BRANCH_NAME-$(git rev-parse --abbrev-ref HEAD)}|sed 's#/#_#g')}

    docker pull ${IMG_NAME}:${GIT_COMMIT_SHA}
    docker tag ${IMG_NAME}:${GIT_COMMIT_SHA} ${DOCKER_IMAGE}:${GIT_COMMIT_SHA}
    docker tag ${IMG_NAME}:${GIT_COMMIT_SHA} ${DOCKER_IMAGE}:${DOCKER_TAG}

    if [[ -n ${GIT_BRANCH_NAME} ]] && [[ "${GIT_BRANCH_NAME}" != "HEAD" ]]; then
      docker pull ${IMG_NAME}:${GIT_BRANCH_NAME}-latest
      docker tag ${IMG_NAME}:${GIT_BRANCH_NAME}-latest ${DOCKER_IMAGE}:${GIT_BRANCH_NAME}-latest
    fi
  else
    docker pull ${IMG_NAME}:${DOCKER_TAG}
    docker tag ${IMG_NAME}:${DOCKER_TAG} ${DOCKER_IMAGE}:${DOCKER_TAG} 
  fi

fi
