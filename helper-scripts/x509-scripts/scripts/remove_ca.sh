#!/bin/bash -e

# SPDX-FileCopyrightText: 2024 Istituto Nazionale di Fisica Nucleare
#
# SPDX-License-Identifier: EUPL-1.2

# don't rely on the CA_NAME env var, but prefer an explicit command line argument

if [ $# -ne 1 ]; then
  >&2 echo "Usage: remove_ca.sh ca-name"
  exit 1
fi

ca_name="$1"

if [ ! -d "${ca_name}" ]; then
  >&2 echo "Directory '${ca_name}' does not exist"
  exit 1
fi

if [ ! -d "${ca_name}/private" ]; then
  >&2 echo "Directory '${ca_name}' does not look like a CA"
  exit 1
fi

rm -r ${ca_name}

echo "Removed CA under ${ca_name}"
