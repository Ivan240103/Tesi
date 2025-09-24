#!/bin/bash -e

# SPDX-FileCopyrightText: 2024 Istituto Nazionale di Fisica Nucleare
#
# SPDX-License-Identifier: EUPL-1.2

if [ $# -ne 1 -o -z "$1" ]; then
  >&2 echo "Usage: $(basename $0) cert-name"
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

cert_file="${CA_NAME}/certs/${cert_name}.cert.pem"

if [ -e "${cert_file}" ]; then
  >&2 echo "A certificate for ${cert_name} in ${CA_NAME} already exists ('${cert_file}')"
  exit 1
fi

conf_file="conf.d/${cert_name}.conf"
if [ ! -e "${conf_file}" ]; then
  >&2 echo "The configuration file '${conf_file}' doesn't exist"
  exit 1
fi

if [ ! -e "openssl.conf" ]; then
  >&2 echo "The configuration file 'openssl.conf' doesn't exist in this directory"
  exit 1
fi

key_file="$(eval echo $(awk -F= '/default_keyfile/ {gsub(/^ +| +$|ENV::/, "", $2); print $2}' ${conf_file}))"
if [[ -z "${key_file}" ]]; then
  key_file=${cert_file%cert.pem}key.pem
fi

pkeyopt="$(awk -F= '/pkeyopt/ {gsub(/^ +| +$/, "", $2); print $2}' ${conf_file})"
if [[ "${pkeyopt}" == ec_paramgen_curve:* ]]; then
  openssl genpkey -algorithm EC -pkeyopt "${pkeyopt}" > "${key_file}"
  minus_key="-key ${key_file}"
fi

openssl req -batch -CA "${CA_NAME}/ca.crt" -CAkey "${CA_NAME}/private/ca.key" -out "${cert_file}" ${minus_key[@]} -text -config openssl.conf -section "${cert_name}"

password="$(awk -F= '/output_password/ {gsub(/^ +| +$/, "", $2); print $2}' ${conf_file})"

openssl pkcs12 -export -out "${cert_file%cert.pem}p12" -in "${cert_file}" -inkey "${key_file}" -passin pass:"$password" -passout pass:"$password"

echo "New certificate in ${cert_file}"
