#!/bin/bash

set -e
set -x

# Activate License
if ! [ -z "$RSC_LICENSE" ]; then
    /opt/rstudio-connect/bin/license-manager activate $RSC_LICENSE
elif test -f "/etc/rstudio-connect/license.lic"; then
    /opt/rstudio-connect/bin/license-manager activate-file /etc/rstudio-connect/license.lic
fi

# Start RStudio Connect
/opt/rstudio-connect/bin/connect --config /etc/rstudio-connect/rstudio-connect.gcfg
