#!/bin/bash
set -eo pipefail
export DEBIAN_FRONTEND=noninteractive

# Output delimiter
d="===="

if [ -z "$DRIVERS_VERSION" ]; then
    echo "$d No DRIVERS_VERSION specified $d"
    exit 1
fi

# Use TARGETARCH if set (Docker builds), otherwise default to amd64
ARCH=${TARGETARCH:-amd64}

# Professional Drivers are only available for amd64
if [ "$ARCH" != "amd64" ]; then
    echo "$d Skipping Professional Drivers installation on $ARCH (only available for amd64) $d"
    exit 0
fi

echo "$d$d Installing Professional Drivers ${DRIVERS_VERSION} $d$d"

drivers_url="https://cdn.rstudio.com/drivers/7C152C12/installer/rstudio-drivers_${DRIVERS_VERSION}_amd64.deb"
curl -fsSL "$drivers_url" -o "/tmp/rstudio-drivers_${DRIVERS_VERSION}_amd64.deb"

apt-get install -y -qq "/tmp/rstudio-drivers_${DRIVERS_VERSION}_amd64.deb"
cat /opt/rstudio-drivers/odbcinst.ini.sample > /etc/odbcinst.ini

rm /tmp/rstudio-drivers_${DRIVERS_VERSION}_amd64.deb
