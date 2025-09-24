#!/busybox/sh
set -e

# Check for env file in current dir
if [ -r "$(pwd)/.env" ]; then 
  set -a
  source "$(pwd)/.env"
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

KANIKO_OPTS=${KANIKO_OPTS:-"--skip-tls-verify --cleanup"}
KANIKO_EXECUTOR=${KANIKO_EXECUTOR:-"/kaniko/executor"}

dest_opts="--destination ${DOCKER_IMAGE}:${DOCKER_TAG}"

echo "Building image ${DOCKER_IMAGE}:${DOCKER_TAG}"

GIT_BRANCH_NAME=$(echo ${GIT_BRANCH}|sed 's#/#_#g')

if [[ -n "${DOCKER_GIT_TAG_ENABLED}" ]] && [[ -n "${GIT_COMMIT}" ]]; then

  COMMIT_IMG_NAME="${DOCKER_IMAGE}:${GIT_COMMIT:0:8}"

  dest_opts="${dest_opts} --destination ${COMMIT_IMG_NAME}"

  echo "Commit tag: ${COMMIT_IMG_NAME}"

  if [[ -n ${GIT_BRANCH_NAME} ]] && [[ "${GIT_BRANCH_NAME}" != "HEAD" ]]; then
    BRANCH_IMG_NAME="${DOCKER_IMAGE}:${GIT_BRANCH_NAME}-latest"
    echo "Branch tag: ${BRANCH_IMG_NAME}"
    dest_opts="${dest_opts} --destination ${BRANCH_IMG_NAME}"
  fi
fi

if [ -z "${DOCKER_PUSH_TO_DOCKERHUB}" ]; then
  dest_opts="${dest_opts} --no-push"
fi

${KANIKO_EXECUTOR} -f "$(pwd)/Dockerfile" -c "$(pwd)" ${KANIKO_OPTS} ${dest_opts}
