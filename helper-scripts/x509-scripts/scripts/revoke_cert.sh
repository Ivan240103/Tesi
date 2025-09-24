#!/bin/bash -e

# SPDX-FileCopyrightText: 2024 Istituto Nazionale di Fisica Nucleare
#
# SPDX-License-Identifier: EUPL-1.2

if [ $# -ne 1 ]; then
  >&2 echo "Usage: revoke_cert.sh cert-name"
  exit 1
fi

cert_name="$1"

if [ -z "${CA_NAME}" ]; then
  >&2 echo "Env var CA_NAME is not set"
  exit 1
fi

if [ ! -d "${CA_NAME}" ]; then
  >&2 echo "Directory '${CA_NAME}' does not exist"
  exit 1
fi

if [ ! -e "${CA_NAME}/certs/${cert_name}.cert.pem" ]; then
  >&2 echo "A certificate for ${cert_name} in ${CA_NAME} doesn't exist"
  exit 1
fi

if [ ! -e "openssl.conf" ]; then
  >&2 echo "The configuration file 'openssl.conf' doesn't exist in this directory"
  exit 1
fi

openssl ca -revoke "${CA_NAME}/certs/${cert_name}.cert.pem" -config openssl.conf -section "${CA_NAME}"

echo "Certificate ${CA_NAME}/certs/${cert_name}.cert.pem is revoked"
