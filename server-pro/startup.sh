#!/bin/bash

set -e
set -x

# Activate License
if ! [ -z "$RSP_LICENSE" ]; then
    rstudio-server license-manager activate $RSP_LICENSE
elif test -f "/etc/rstudio-server/license.lic"; then
    rstudio-server license-manager activate-file /etc/rstudio-server/license.lic
fi

# Create one user
if ! [ -z "$RSP_TESTUSER" ]; then
    useradd -m -s /bin/bash -N -u $RSP_TESTUSER_UID $RSP_TESTUSER
    echo $RSP_TESTUSER_PASSWD | passwd $RSP_TESTUSER --stdin
fi

# Start Server Pro
/usr/lib/rstudio-server/bin/rstudio-launcher > /dev/null 2>&1 &
wait-for-it.sh localhost:5559 -t 0
/usr/lib/rstudio-server/bin/rserver
wait-for-it.sh localhost:8787 -t 0
tail -f /var/lib/rstudio-server/monitor/log/*.log /var/lib/rstudio-launcher/*.log /var/lib/rstudio-launcher/Local/*.log
