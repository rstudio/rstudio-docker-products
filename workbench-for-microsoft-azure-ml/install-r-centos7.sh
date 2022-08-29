#!/bin/bash

set -euxo pipefail

# quick way to call out specific logging lines in packer stdout
pp() {
  printf "============== %s ==============\n" "$1"
}

install_r_packages() {
  # given a one-per-line file of R packages, parses the file and installs those R
  # packages to the provided (or default) R installation.

  set -xe

  local OS_CODENAME="centos7"

  # passing a r binary as second arg will install with that R version
  local R_BIN=${2:-"/usr/lib/R/bin/R"}

  # passing a CRAN repo as third arg will install from that repo, in this case however,
  # we are using the RStudio public package manager so we can install from binaries and not source
  # this speeds everything up dramatically
  local CRAN_REPO=${3:-"https://packagemanager.rstudio.com/cran/__linux__/${OS_CODENAME}/latest"}

  # create an R matrix-style string of packages
  local r_packages=$(awk '{print "\"" $0 "\""}' "$1" | paste -d',' -s  -)

  # install packages enumerated in the file to the R binary passed
  pp "Installing R packages for $R_BIN"
  $R_BIN --slave -e "install.packages(c(${r_packages}), repos = \"${CRAN_REPO}\")" > /dev/null
}

for rvers in 3.3.3 3.4.4 3.5.3 3.6.3 4.0.5 4.1.2; do
    # install r version
    curl -O https://cdn.rstudio.com/r/centos-7/pkgs/R-${rvers}-1-1.x86_64.rpm
    yum install -y R-${rvers}-1-1.x86_64.rpm
    rm -f ./R-${rvers}-1-1.x86_64.rpm

    # install packages
    install_r_packages /tmp/package-list.txt /opt/R/${rvers}/bin/R https://packagemanager.rstudio.com/cran/__linux__/centos7/latest
done

rm -f /tmp/package_list.txt