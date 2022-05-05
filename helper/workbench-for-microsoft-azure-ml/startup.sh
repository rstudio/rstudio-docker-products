#!/bin/bash

set -e
set -x

# Deactivate license when the process exits
deactivate() {
    echo "== Exiting =="
    rstudio-server stop
    echo "Deactivating license ..."
    /usr/lib/rstudio-server/bin/license-manager deactivate >/dev/null 2>&1

    echo "== Done =="
}
trap deactivate EXIT

verify_installation(){
   echo "==VERIFY INSTALLATION==";
   mkdir -p $DIAGNOSTIC_DIR
   chmod 777 $DIAGNOSTIC_DIR
   rstudio-server verify-installation --verify-user=$USER_NAME | tee $DIAGNOSTIC_DIR/verify.log
}

# Support RSP_ or RSW_ prefix
RSP_LICENSE=${RSP_LICENSE:-${RSW_LICENSE}}
RSP_LICENSE_SERVER=${RSP_LICENSE_SERVER:-${RSW_LICENSE_SERVER}}

# Activate License
RSW_LICENSE_FILE_PATH=${RSW_LICENSE_FILE_PATH:-/etc/rstudio-server/license.lic}
if [ -n "$RSP_LICENSE" ]; then
    /usr/lib/rstudio-server/bin/license-manager activate $RSP_LICENSE || true
elif [ -n "$RSP_LICENSE_SERVER" ]; then
    /usr/lib/rstudio-server/bin/license-manager license-server $RSP_LICENSE_SERVER || true
elif test -f "$RSW_LICENSE_FILE_PATH"; then
    /usr/lib/rstudio-server/bin/license-manager activate-file $RSW_LICENSE_FILE_PATH || true
fi

# ensure these cannot be inherited by child processes
unset RSP_LICENSE
unset RSP_LICENSE_SERVER
unset RSW_LICENSE
unset RSW_LICENSE_SERVER

# Create one user
if [ $(getent passwd $PUID) ] ; then
    echo "UID $PUID already exists, not creating $USER_NAME test user";
else
    if [ -z "$USER_NAME" ]; then
        echo "Empty 'USER_NAME' variables, not creating test user";
    else
        groupadd -g $PGID $USER_NAME
        useradd -m -s /bin/bash -N -u $PUID -g $PGID $USER_NAME
        if [ -n "$USER_PASSWORD" ] ; then
            echo "$USER_NAME:$USER_PASSWORD" | sudo chpasswd;
        fi
    fi
fi

# Start Launcher
if [ "$RSW_LAUNCHER" == "true" ]; then
  echo "Waiting for launcher to startup... to disable set RSW_LAUNCHER=false"
  wait-for-it.sh localhost:5559 -t $RSW_LAUNCHER_TIMEOUT
fi

# Check diagnostic configurations
if [ "$DIAGNOSTIC_ENABLE" == "true" ]; then
  verify_installation
  if [ "$DIAGNOSTIC_ONLY" == "true" ]; then
    echo $(<$DIAGNOSTIC_DIR/verify.log);
    echo "Exiting script because DIAGNOSTIC_ONLY=${DIAGNOSTIC_ONLY}";
    exit 0
  fi;
else
  echo "not running verify installation because DIAGNOSTIC_ENABLE=${DIAGNOSTIC_ENABLE}";
fi

# the main container process
# cannot use "exec" or the "trap" will be lost
/usr/lib/rstudio-server/bin/rserver --server-daemonize 0 > /dev/stderr
