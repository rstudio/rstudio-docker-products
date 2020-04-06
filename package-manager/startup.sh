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
if ! [ -z "$RSPM_LICENSE" ]; then
    /opt/rstudio-pm/bin/license-manager activate $RSPM_LICENSE
elif ! [ -z "$RSPM_LICENSE_SERVER" ]; then
    /opt/rstudio-pm/bin/license-manager license-server $RSPM_LICENSE_SERVER
elif test -f "/etc/rstudio-pm/license.lic"; then
    /opt/rstudio-pm/bin/license-manager activate-file /etc/rstudio-pm/license.lic
fi

# lest this be inherited by child processes
unset RSPM_LICENSE
unset RSPM_LICENSE_SERVER

# Start RStudio Package Manager
/opt/rstudio-pm/bin/rstudio-pm --config /etc/rstudio-pm/rstudio-pm.gcfg
