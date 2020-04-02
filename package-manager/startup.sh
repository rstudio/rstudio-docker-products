#!/bin/bash

set -e
set -x

# Deactivate license when it exists
deactivate() {
    echo "Deactivating license ..."
    /opt/rstudio-pm/bin/license-manager deactivate >/dev/null 2>&1
}
trap deactivate EXIT

# Activate License
if ! [ -z "$LICENSE" ]; then
    /opt/rstudio-pm/bin/license-manager activate $LICENSE
elif ! [ -z "$LICENSE_SERVER" ]; then
    /opt/rstudio-pm/bin/license-manager license-server $LICENSE_SERVER
elif test -f "/etc/rstudio-pm/license.lic"; then
    /opt/rstudio-pm/bin/license-manager activate-file /etc/rstudio-pm/license.lic
fi

# lest this be inherited by child processes
unset LICENSE
unset LICENSE_SERVER

# Start RStudio Package Manager
/opt/rstudio-pm/bin/rstudio-pm --config /etc/rstudio-pm/rstudio-pm.gcfg
