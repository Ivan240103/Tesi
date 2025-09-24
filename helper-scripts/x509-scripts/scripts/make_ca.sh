#!/bin/bash -e

# SPDX-FileCopyrightText: 2024 Istituto Nazionale di Fisica Nucleare
#
# SPDX-License-Identifier: EUPL-1.2

# take the CA_NAME from the env as an additional check for the existence
# of the env var, which is then used in other scripts

if [ $# -ne 0 ]; then
  >&2 echo "Usage: $(basename $0) (the CA is taken from the CA_NAME env var)"
  exit 1
fi

if [ -z "${CA_NAME}" ]; then
  >&2 echo "Env var CA_NAME is not set"
  exit 1
fi

if [ -e "${CA_NAME}" ]; then
  >&2 echo "File or directory '${CA_NAME}' already exists"
  exit 1
fi

if [ ! -e "conf.d/${CA_NAME}.conf" ]; then
  >&2 echo "The configuration file 'conf.d/${CA_NAME}.conf' doesn't exist"
  exit 1
fi

if [ ! -e "openssl.conf" ]; then
  >&2 echo "The configuration file 'openssl.conf' doesn't exist in this directory"
  exit 1
fi

mkdir -p "${CA_NAME}" "${CA_NAME}"/private "${CA_NAME}"/certs
touch "${CA_NAME}"/index.txt "${CA_NAME}"/serial

cert_file=ca.crt
openssl req -batch -x509 -new -out "${CA_NAME}/${cert_file}" -config openssl.conf -section ${CA_NAME}_cert

subject="$(openssl x509 -in ${CA_NAME}/${cert_file} -noout -subject -nameopt compat | sed 's/^subject=//')"
namespace="$(echo ${subject} | sed 's:/CN=.*$::')"

cat > "${CA_NAME}/ca.signing_policy" <<EOF
access_id_CA      X509         '${subject}'
pos_rights        globus        CA:sign
cond_subjects     globus       '"${namespace}/*"'
EOF

cat > "${CA_NAME}/ca.namespaces" <<EOF
TO Issuer "${subject}" \\
    PERMIT Subject "${namespace}/.*"
EOF

subject_hash=$(openssl x509 -in "${CA_NAME}/${cert_file}" -noout -subject_hash)
subject_hash_old=$(openssl x509 -in "${CA_NAME}/${cert_file}" -noout -subject_hash_old)
ln -s ${cert_file} "${CA_NAME}/${subject_hash}.0"
ln -s ${cert_file} "${CA_NAME}/${subject_hash_old}.0"
ln -s ca.signing_policy ${CA_NAME}/${subject_hash}.signing_policy
ln -s ca.signing_policy ${CA_NAME}/${subject_hash_old}.signing_policy
ln -s ca.namespaces ${CA_NAME}/${subject_hash}.namespaces
ln -s ca.namespaces ${CA_NAME}/${subject_hash_old}.namespaces

echo "Created CA under '${CA_NAME}'"
