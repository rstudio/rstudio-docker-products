#!/bin/bash

# only install quarto if python 3.10 and R 4.1
# TODO: figure out a different hierarchy...
if [[ `ls /opt/python/ | grep '3\.10\.'` ]] && [[ `ls /opt/R | grep '4\.1\.'` ]]; then 
  echo '--> Installing Quarto'
  curl -L -o /quarto.deb https://github.com/quarto-dev/quarto-cli/releases/download/v0.9.344/quarto-0.9.344-linux-amd64.deb
  apt install /quarto.deb
  rm -f /quarto.deb
fi
