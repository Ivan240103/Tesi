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

if [ ! -d "${ca_name}" ]; then
  >&2 echo "Directory '${ca_name}' does not exist"
  exit 1
fi

if [ ! -d "${ca_name}/private" ]; then
  >&2 echo "Directory '${ca_name}' does not look like a CA"
  exit 1
fi

if [ ! -d "${install_dir}" ]; then
  >&2 echo "Directory '${install_dir}' does not exist"
  exit 1
fi

cp "${ca_name}/ca.crt"            "${install_dir}/${ca_name}.pem"
cp "${ca_name}/ca.crl"            "${install_dir}/${ca_name}.crl"
cp "${ca_name}/ca.namespaces"     "${install_dir}/${ca_name}.namespaces"
cp "${ca_name}/ca.signing_policy" "${install_dir}/${ca_name}.signing_policy"

subject_hash=$(openssl x509 -in "${ca_name}/ca.crt" -noout -subject_hash)
subject_hash_old=$(openssl x509 -in "${ca_name}/ca.crt" -noout -subject_hash_old)

pushd "${install_dir}" > /dev/null
ln -s "${ca_name}.pem" "${subject_hash}.0"
ln -s "${ca_name}.pem" "${subject_hash_old}.0"
ln -s "${ca_name}.crl" "${subject_hash}.r0"
ln -s "${ca_name}.crl" "${subject_hash_old}.r0"
ln -s "${ca_name}.namespaces" "${subject_hash}.namespaces"
ln -s "${ca_name}.namespaces" "${subject_hash_old}.namespaces"
ln -s "${ca_name}.signing_policy" "${subject_hash}.signing_policy"
ln -s "${ca_name}.signing_policy" "${subject_hash_old}.signing_policy"
popd > /dev/null
