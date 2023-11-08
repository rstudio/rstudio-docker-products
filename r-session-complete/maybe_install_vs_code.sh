#!/bin/bash

set -ex

major=$(echo ${RSW_VERSION} | cut -d. -f1)
minor=$(echo ${RSW_VERSION} | cut -d. -f2)
if [ ${major} -lt 2022 ] || [ ${major} -eq 2022 ] && [ ${minor} -lt 12 ]; then
  echo "Installing VS Code"
  rstudio-server install-vs-code /opt/code-server/
  ln -s /opt/code-server/bin/code-server /usr/local/bin/code-server
else
  echo "VS Code is already installed"
fi
