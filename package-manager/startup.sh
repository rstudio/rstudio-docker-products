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
RSPM_LICENSE_FILE_PATH=${RSPM_LICENSE_FILE_PATH:-/etc/rstudio-pm/license.lic}
if ! [ -z "$RSPM_LICENSE" ]; then
    /opt/rstudio-pm/bin/license-manager activate $RSPM_LICENSE
elif ! [ -z "$RSPM_LICENSE_SERVER" ]; then
    /opt/rstudio-pm/bin/license-manager license-server $RSPM_LICENSE_SERVER
elif test -f "$RSPM_LICENSE_FILE_PATH"; then
    /opt/rstudio-pm/bin/license-manager activate-file $RSPM_LICENSE_FILE_PATH
fi

# ensure these cannot be inherited by child processes
unset RSPM_LICENSE
unset RSPM_LICENSE_SERVER

# Start RStudio Package Manager
/opt/rstudio-pm/bin/rstudio-pm --config /etc/rstudio-pm/rstudio-pm.gcfg
