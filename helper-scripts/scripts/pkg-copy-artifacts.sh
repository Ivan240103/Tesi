#!/bin/bash
set -ex

docker run -i --rm \
  -e U_ID=$(id -u) \
  -e U_GID=$(id -g) \
  -v ${PACKAGES_VOLUME}:/packages \
  -v ${STAGE_AREA_VOLUME}:/stage-area \
  -v ${COPY_ARTIFACTS_DIR:-$(pwd)/artifacts}:/artifacts \
  centos:7 \
  /bin/bash -ex -c 'ls -lR /packages /stage-area && mkdir artifacts/packages artifacts/stage-area && mv /packages/* /artifacts/packages && mv /stage-area/* /artifacts/stage-area && chown -R ${U_ID}:${U_GID} /artifacts && ls -lR /artifacts'
