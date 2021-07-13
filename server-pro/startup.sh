#!/bin/bash

set -e
set -x

# Deactivate license when it exists
deactivate() {
    echo "Deactivating license ..."
    /usr/lib/rstudio-server/bin/license-manager deactivate >/dev/null 2>&1

    echo "== Done =="
}
trap deactivate EXIT

# Activate License
if ! [ -z "$RSP_LICENSE" ]; then
    /usr/lib/rstudio-server/bin/license-manager activate $RSP_LICENSE
elif ! [ -z "$RSP_LICENSE_SERVER" ]; then
    /usr/lib/rstudio-server/bin/license-manager license-server $RSP_LICENSE_SERVER
elif test -f "/etc/rstudio-server/license.lic"; then
    /usr/lib/rstudio-server/bin/license-manager activate-file /etc/rstudio-server/license.lic
fi

# lest this be inherited by child processes
unset RSP_LICENSE
unset RSP_LICENSE_SERVER

# Create one user
if [ $(getent passwd $RSP_TESTUSER_UID) ] ; then
    echo "UID $RSP_TESTUSER_UID already exists, not creating $RSP_TESTUSER test user";
else
    if [ -z "$RSP_TESTUSER" ]; then
        echo "Empty 'RSP_TESTUSER' variables, not creating test user";
    else
        useradd -m -s /bin/bash -N -u $RSP_TESTUSER_UID $RSP_TESTUSER
        echo "$RSP_TESTUSER:$RSP_TESTUSER_PASSWD" | sudo chpasswd
    fi
fi

# Start Launcher
if [ "$RSP_LAUNCHER" == "true" ]; then
  /usr/lib/rstudio-server/bin/rstudio-launcher 1>&2 &
  wait-for-it.sh localhost:5559 -t $RSP_LAUNCHER_TIMEOUT
fi

# the main container process
# cannot use "exec" or the "trap" will be lost
/usr/lib/rstudio-server/bin/rserver --server-daemonize 0 > /dev/stderr
