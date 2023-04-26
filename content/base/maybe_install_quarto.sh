#!/bin/bash

# on bionic, only install quarto if python 3.10 and R 4.1
# TODO: figure out a different hierarchy...
if [[ `grep -oE bionic /etc/lsb-release` ]] && [[ `ls /opt/python/ | grep '3\.10\.'` ]] && [[ `ls /opt/R | grep '4\.1\.'` ]]; then
  qver=${QUARTO_VERSION:-1.0.37}
  echo '--> Installing Quarto'
  curl -L -o /quarto.deb https://github.com/quarto-dev/quarto-cli/releases/download/v${qver}/quarto-${qver}-linux-amd64.deb
  apt install /quarto.deb
  rm -f /quarto.deb
fi

# on jammy, always install quarto
if [[ `grep -oE jammy /etc/lsb-release` ]]; then
  qver=${QUARTO_VERSION:-1.3.330}
  echo '--> Installing Quarto'
  curl -L -o /quarto.deb https://github.com/quarto-dev/quarto-cli/releases/download/v${qver}/quarto-${qver}-linux-amd64.deb
  apt install /quarto.deb
  rm -f /quarto.deb
fi
