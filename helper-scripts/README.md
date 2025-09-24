# helper-scripts

This repository holds a set of helper-scripts used in CNAF SD CI/CD
infrastructure

The [x509-scripts](x509-scripts) directory contains a collection of scripts to manage
a Certification Authority for testing purposes.

The recommended way to use this repository is to clone when needed and add the
`scripts` and/or the `x509-scripts/scripts` directories to the `PATH`, for example:

```shell
git clone --depth 1 https://baltig.infn.it/mw-devel/helper-scripts.git
PATH=$(pwd)/helper-scripts/scripts:$(pwd)/helper-scripts/x509-scripts/scripts:$PATH
```
