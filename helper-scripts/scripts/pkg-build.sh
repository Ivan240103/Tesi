#!/bin/bash

set -ex

set -a
source ./build-env
set +a

if [ -z "${PLATFORM}" ]; then
  echo "PLATFORM is not defined"
  exit 1
fi

p_comp_var_name="COMPONENTS_${PLATFORM}"

# Allow to define components that are built only on specific platforms
if [ -n "${!p_comp_var_name}" ]; then
  if [ -z "${COMPONENTS}" ]; then
    COMPONENTS=${!p_comp_var_name}
  else
    COMPONENTS="${COMPONENTS} ${!p_comp_var_name}"
  fi
fi

if [ -z "${COMPONENTS}" ]; then
  echo "COMPONENTS is not defined"
  exit 1
fi

pkg_base_image_name="italiangrid/pkg.base:${PLATFORM}"
volumes_conf=${PKG_VOLUMES_CONF:-""}

if [ -n "${USE_DOCKER_REGISTRY}" ]; then
  pkg_base_image_name="${DOCKER_REGISTRY_HOST}/${pkg_base_image_name}"
fi

if [ -z "${PKG_VOLUMES_CONF}" ]; then
  if [ -n "${MVN_REPO_VOLUME}" ]; then
    volumes_conf="${volumes_conf} -v ${MVN_REPO_VOLUME}:/m2-repository"
  fi 

  if [ -n "${STAGE_AREA_VOLUME}" ]; then
    volumes_conf="${volumes_conf} -v ${STAGE_AREA_VOLUME}:/stage-area"
  fi

  if [ -n "${PACKAGES_VOLUME}" ]; then
    volumes_conf="${volumes_conf} -v ${PACKAGES_VOLUME}:/packages"
  fi
fi

# Run packaging
for c in ${COMPONENTS}; do
  build_env_file="$c/build-env"
  comp_name=$(echo ${c} | tr '[:lower:]' '[:upper:]' | tr '-' '_')
  
  var_names="BUILD_REPO PKG_PACKAGES_DIR PKG_STAGE_DIR PKG_TAG PKG_REPO PKG_STAGE_RPMS PKG_STAGE_SRPMS PKG_PUBLISH_PACKAGES PKG_NEXUS_USERNAME PKG_NEXUS_PASSWORD PKG_NEXUS_REPONAME PKG_NEXUS_HOST PKG_SIGN_PACKAGES PKG_SIGN_KEY_PASSWORD PKG_SIGN_PUB_KEY PKG_SIGN_PRI_KEY GPG_IMPORT_OPTS"
  
  ## Add component variable overrides
  for v in ${var_names}; do
    c_var_name="${v}_${comp_name}"

    if [ -n "${!c_var_name}" ]; then
      build_env="${build_env} -e ${v}=${!c_var_name}"
    elif [ -n "${!v}" ]; then
        build_env="${build_env} -e ${v}=${!v}"
    fi
  done

  ## Add platform variable overrides
  for v in ${var_names}; do
    p_var_name="${v}_${PLATFORM}"

    if [ -n "${!p_var_name}" ]; then
      build_env="${build_env} -e ${v}=${!p_var_name}"
    elif [ -n "${!v}" ]; then
      build_env="${build_env} -e ${v}=${!v}"
    fi
  done
 
  if [ "${INCLUDE_BUILD_NUMBER}" == "1" ]; then
    build_env="${build_env} -e BUILD_NUMBER=${PKG_BUILD_NUMBER:-test}"
  fi

  if [ -z "${PKG_SKIP_PULL}" ]; then
    docker pull ${pkg_base_image_name}
  fi

  docker run -i \
    ${volumes_conf} \
    ${DOCKER_ARGS} \
    --env-file ${build_env_file} \
    ${build_env} \
    ${pkg_base_image_name} \
    ${PKG_TARGET}
done
