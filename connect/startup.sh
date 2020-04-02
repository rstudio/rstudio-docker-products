#!/bin/bash

set -e
set -x

# Deactivate license when it exists
deactivate() {
    echo "Deactivating license ..."
    /opt/rstudio-connect/bin/license-manager deactivate >/dev/null 2>&1
}
trap deactivate EXIT

# Activate License
if ! [ -z "$RSP_LICENSE" ]; then
    /opt/rstudio-connect/bin/license-manager activate $RSP_LICENSE
elif ! [ -z "$RSP_LICENSE_SERVER" ]; then
    /opt/rstudio-connect/bin/license-manager license-server $RSP_LICENSE_SERVER
elif test -f "/etc/rstudio-connect/license.lic"; then
    /opt/rstudio-connect/bin/license-manager activate-file /etc/rstudio-connect/license.lic
fi

# lest this be inherited by child processes
unset RSP_LICENSE
unset RSP_LICENSE_SERVER

# Start RStudio Connect
/opt/rstudio-connect/bin/connect --config /etc/rstudio-connect/rstudio-connect.gcfg
