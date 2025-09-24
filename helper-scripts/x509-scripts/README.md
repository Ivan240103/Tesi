<!--
SPDX-FileCopyrightText: 2024 Istituto Nazionale di Fisica Nucleare

SPDX-License-Identifier: EUPL-1.2
-->

# X.509 Scripts

Collection of scripts to manage a Certification Authority for testing purposes.

## Manage Certificate Authorities and end-entity certificates

Certificates are generated based on information kept as much as possible in a modular OpenSSL configuration file: for every certificate to generate a new module is first created in the `conf.d` directory. The modules are then collected by a top-level `openssl.conf` file.

### Boot a Certification Authority

`Usage: make_ca.sh`

Setup a minimal directory tree to keep CA information:

- certificates and private key
- namespace files
- symbolic links to certificate and namespace files from subject hashes (new and old)

A _namespace file_ is a file specifying the name space of Distinguished Names
for whom the CA will issue a certificate. Two formats are available, each
characterized by a filename extension: `.namespaces` or `.signing_policy`.

In the same directory the CRL and EE certificates will be created by `make_crl.sh` and `make_cert.sh`.

The name of the CA (which corresponds to a section in the configuration file and to the CA directory) is taken from the env variable `CA_NAME`, which must exist.

See `conf.d/ephemeral_ca.conf` for a tipical configuration section.

Example usage:

```shell
$ env CA_NAME=ephemeral_ca make_ca.sh
.+......+...
-----
Created CA under 'ephemeral_ca'
```

### Remove a CA

`Usage: remove_ca.sh ca-name`

Remove recursively all files and directories, including the top directory, created by `make_ca.sh` and following commands.

Example usage:

```shell
$ remove_ca.sh ephemeral_ca
Removed CA under ephemeral_ca
```

### Create an EE certificate

`Usage: make_cert.sh cert-name`

Generate a certificate based on the information specified in an OpenSSL
configuration file named correspondingly, included in the `conf.d` directory.
The configuration file contains a section with the same name. The name of the
CA, which must have already been created with `make_ca.sh`, is taken from the env variable CA_NAME.

See `conf.d/test0.conf` for a tipical configuration section.

The certificate and the corresponding private key are in PEM format and they
are named _cert-name_`.cert.pem` and _cert-name_`.key.pem` respectively. The
certificate and private key are also wrapped in a PKCS#12 file, named
_cert-name_`.p12`. The private key and the PKCS#12 file are protected by the
same password, if set in the configuration.

All the files are put in the subdirectory `certs` of the CA directory.

Example usage:

```shell
$ cat conf.d/test0.conf
[ test0 ]

default_bits           = 2048
default_keyfile        = ${ENV::CA_NAME}/certs/test0.key.pem
distinguished_name     = test0_dn
...
$ env CA_NAME=ephemeral_ca make_cert.sh test0
..+...+....
...
-----
New certificate in ephemeral_ca/certs/test0.cert.pem
```

To create an expired certificate you can use the `faketime` utility. For example:

```shell
$ date
Thu Dec  5 16:54:43 UTC 2024
$ faketime -f -1y env CA_NAME=ephemeral_ca make_cert.sh expired
.+....+...
...
-----
New certificate in ephemeral_ca/certs/expired.cert.pem
$ openssl x509 -in ephemeral_ca/certs/expired.cert.pem -noout -dates
notBefore=Dec  6 16:54:45 2023 GMT
notAfter=Jan  5 16:54:45 2024 GMT
```

### Revoke a certificate

`Usage: revoke_cert.sh cert-name`

Revokes an already issued certificate.

Example usage:

```shell
$ env CA_NAME=ephemeral_ca make_cert.sh revoked
...
$ env CA_NAME=ephemeral_ca revoke_cert.sh revoked
Using configuration from openssl.conf
Adding Entry with serial number 52002AFE925899453E1AA29C00FF31F80E8B16F6 to DB for /C=IT/O=IGI/CN=Revoked
Revoking Certificate 52002AFE925899453E1AA29C00FF31F80E8B16F6.
Data Base Updated
Certificate ephemeral_ca/certs/revoked.cert.pem is revoked
```

### Generate a Certificate Revocation List

`Usage: make_crl.sh`

Produces a CRL file based on the certificates revoked so far for a given CA. The name of the
CA is taken from the env variable CA_NAME. The file is called `ca.crl`; two symbolic links,
with extension `.r0`, are created using the subject hash (new and old).

Example usage:

```shell
$ env CA_NAME=ephemeral_ca make_crl.sh
Using configuration from openssl.conf
New CRL for CA ephemeral_ca in ephemeral_ca/ca.crl
```

### Install a CA

`Usage: install_ca.sh ca-name [directory]`

Installs the certificate, CRL, namespace files and corresponding symbolic links from subject hashes (new and old)
for the specified CA in the given directory, which must exist. By default the directory is `/etc/grid-security/certificates`.

Example usage:

```shell
$ mkdir /tmp/trust
$ install_ca.sh ephemeral_ca /tmp/trust
$ ls /tmp/trust
a4c9e7bb.0           a4c9e7bb.r0              a5de37b0.0           a5de37b0.r0              ephemeral_ca.crl         ephemeral_ca.pem
a4c9e7bb.namespaces  a4c9e7bb.signing_policy  a5de37b0.namespaces  a5de37b0.signing_policy  ephemeral_ca.namespaces  ephemeral_ca.signing_policy
```

### Uninstall a CA

`Usage: uninstall_ca.sh ca-name [directory]`

Removes all files for the specified CA, which was previously installed in the given
directory. By default the directory is `/etc/grid-security/certificates`.

Example usage:

```shell
$ uninstall_ca.sh ephemeral_ca /tmp/trust
$ ls /tmp/trust
$
```
