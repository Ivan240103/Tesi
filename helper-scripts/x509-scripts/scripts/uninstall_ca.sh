#!/bin/bash -e

# SPDX-FileCopyrightText: 2024 Istituto Nazionale di Fisica Nucleare
#
# SPDX-License-Identifier: EUPL-1.2

if [ $# -ne 1 -a $# -ne 2 ]; then
  >&2 echo "Usage: $(basename $0) ca-name [directory]"
  exit 1
fi

ca_name="${1%/}"
install_dir="/etc/grid-security/certificates"
if [ $# -eq 2 ]; then
  install_dir="$2"
fi

if [ ! -d "${install_dir}" ]; then
  >&2 echo "Directory '${install_dir}' does not exist"
  exit 1
fi

pushd "${install_dir}" > /dev/null

if [ ! -e "${ca_name}.pem" ]; then
  >&2 echo "${ca_name} is not installed in ${install_dir}"
  exit 1
fi

subject_hash=$(openssl x509 -in "${ca_name}.pem" -noout -subject_hash)
subject_hash_old=$(openssl x509 -in "${ca_name}.pem" -noout -subject_hash_old)

rm \
  "${ca_name}.pem" "${ca_name}.crl" "${ca_name}.namespaces" "${ca_name}.signing_policy" \
  "${subject_hash}.0" "${subject_hash_old}.0"                                           \
  "${subject_hash}.r0" "${subject_hash_old}.r0"                                         \
  "${subject_hash}.namespaces" "${subject_hash_old}.namespaces"                         \
  "${subject_hash}.signing_policy" "${subject_hash_old}.signing_policy"

popd > /dev/null
