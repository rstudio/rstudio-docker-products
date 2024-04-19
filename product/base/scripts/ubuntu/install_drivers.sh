#!/bin/bash
set -eo pipefail
export DEBIAN_FRONTEND=noninteractive

# Output delimiter
d="===="

if [ -z "$DRIVERS_VERSION" ]; then
    echo "$d No DRIVERS_VERSION specified $d"
    exit 1
fi

echo "$d$d Installing Professional Drivers ${DRIVERS_VERSION} $d$d"

drivers_url="https://cdn.rstudio.com/drivers/7C152C12/installer/rstudio-drivers_${DRIVERS_VERSION}_amd64.deb"
curl -sL "$drivers_url" -o "/tmp/rstudio-drivers_${DRIVERS_VERSION}_amd64.deb"

apt-get install -y -qq "/tmp/rstudio-drivers_${DRIVERS_VERSION}_amd64.deb"
cat /opt/rstudio-drivers/odbcinst.ini.sample > /etc/odbcinst.ini

rm /tmp/rstudio-drivers_${DRIVERS_VERSION}_amd64.deb
