#!/bin/bash

export LICENSE_MANAGER_PATH=${LICENSE_MANAGER_PATH:-/opt/rstudio-license}

set -e
set -x

# Deactivate license when the process exits
deactivate() {
    echo "== Exiting =="
    rstudio-server stop
    echo "Deactivating license ..."
    ${LICENSE_MANAGER_PATH}/license-manager deactivate >/dev/null 2>&1

    echo "== Done =="
}
trap deactivate EXIT

verify_installation(){
   echo "==VERIFY INSTALLATION==";
   mkdir -p $DIAGNOSTIC_DIR
   chmod 777 $DIAGNOSTIC_DIR
   rstudio-server verify-installation --verify-user=$RSW_TESTUSER | tee $DIAGNOSTIC_DIR/verify.log 
}

# Support RSP_ or RSW_ prefix
RSP_LICENSE=${RSP_LICENSE:-${RSW_LICENSE}}
RSP_LICENSE_SERVER=${RSP_LICENSE_SERVER:-${RSW_LICENSE_SERVER}}

# Activate License
RSW_LICENSE_FILE_PATH=${RSW_LICENSE_FILE_PATH:-/etc/rstudio-server/license.lic}
if [ -n "$RSP_LICENSE" ]; then
    ${LICENSE_MANAGER_PATH}/license-manager activate $RSP_LICENSE || true
elif [ -n "$RSP_LICENSE_SERVER" ]; then
    ${LICENSE_MANAGER_PATH}/license-manager license-server $RSP_LICENSE_SERVER || true
elif test -f "$RSW_LICENSE_FILE_PATH"; then
    ${LICENSE_MANAGER_PATH}/license-manager activate-file $RSW_LICENSE_FILE_PATH || true
fi

# ensure these cannot be inherited by child processes
unset RSP_LICENSE
unset RSP_LICENSE_SERVER
unset RSW_LICENSE
unset RSW_LICENSE_SERVER

# Create one user
if [ $(getent passwd $RSW_TESTUSER_UID) ] ; then
    echo "UID $RSW_TESTUSER_UID already exists, not creating $RSW_TESTUSER test user";
else
    if [ -z "$RSW_TESTUSER" ]; then
        echo "Empty 'RSW_TESTUSER' variables, not creating test user";
    else
        useradd -m -s /bin/bash -N -u $RSW_TESTUSER_UID $RSW_TESTUSER
        echo "$RSW_TESTUSER:$RSW_TESTUSER_PASSWD" | sudo chpasswd
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
