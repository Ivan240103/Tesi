#!/bin/bash -e

# SPDX-FileCopyrightText: 2024 Istituto Nazionale di Fisica Nucleare
#
# SPDX-License-Identifier: EUPL-1.2

if [ -z "${CA_NAME}" ]; then
  >&2 echo "Env var CA_NAME is not set"
  exit 1
fi

if [ ! -d "${CA_NAME}" ]; then
  >&2 echo "Directory '${CA_NAME}' does not exist"
  exit 1
fi

if [ ! -e "openssl.conf" ]; then
  >&2 echo "The configuration file 'openssl.conf' doesn't exist in this directory"
  exit 1
fi

openssl ca -gencrl -out "${CA_NAME}/ca.crl" -config openssl.conf -section "${CA_NAME}"

subject_hash=$(openssl x509 -in "${CA_NAME}/ca.crt" -noout -subject_hash)
subject_hash_old=$(openssl x509 -in "${CA_NAME}/ca.crt" -noout -subject_hash_old)
ln -sf ca.crl "${CA_NAME}/${subject_hash}.r0"
ln -sf ca.crl "${CA_NAME}/${subject_hash_old}.r0"

echo "New CRL for CA ${CA_NAME} in ${CA_NAME}/ca.crl"
