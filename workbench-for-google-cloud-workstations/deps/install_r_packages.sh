#!/bin/bash

set -ex

UBUNTU_CODENAME=$(lsb_release -cs)
CRAN_REPO="https://packagemanager.posit.co/cran/__linux__/${UBUNTU_CODENAME}/latest"

r_packages=$(awk '{print "\"" $0 "\""}' r_packages.txt | paste -d',' -s  -)
/opt/R/${R_VERSION}/bin/R --slave -e "install.packages(c(${r_packages}), repos = \"${CRAN_REPO}\")"
/opt/R/${R_VERSION_ALT}/bin/R --slave -e "install.packages(c(${r_packages}), repos = \"${CRAN_REPO}\")"
