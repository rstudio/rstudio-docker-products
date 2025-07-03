#!/bin/bash

set -e
if [[ "${STARTUP_DEBUG_MODE:-0}" -eq 1 ]]; then
  set -x
fi

# Deactivate license when the process exits
deactivate() {
    echo "== Exiting =="
    rstudio-server stop

    echo "Deactivating license ..."
    is_deactivated=0
    retries=0
    while [[ $is_deactivated -ne 1 ]] && [[ $retries -le 3 ]]; do
      /usr/lib/rstudio-server/bin/license-manager deactivate >/dev/null 2>&1
      is_deactivated=1
      ((retries+=1))
      for file in $(ls -A /var/lib/.local); do
        if [ -s /var/lib/.local/$file ]; then
          if [[ $retries -lt 3 ]]; then
            echo "License did not deactivate, retry ${retries}..."
            is_deactivated=0
          else
            echo "Unable to deactivate license. If you encounter issues activating your product in the future, please contact Posit support."
          fi
          continue
        fi
      done
    done
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
RSW_LICENSE_FILE_PATH=${RSW_LICENSE_FILE_PATH:-${RSP_LICENSE_FILE_PATH:-/etc/rstudio-server/license.lic}}
if [ -n "$RSP_LICENSE" ]; then
    /usr/lib/rstudio-server/bin/license-manager activate $RSP_LICENSE
elif [ -n "$RSP_LICENSE_SERVER" ]; then
    /usr/lib/rstudio-server/bin/license-manager license-server $RSP_LICENSE_SERVER
elif test -f "${RSW_LICENSE_FILE_PATH}"; then
    rm -f /var/lib/rstudio-server/*.lic
    cp "${RSW_LICENSE_FILE_PATH}" /var/lib/rstudio-server/license.lic
    chown rstudio-server /var/lib/rstudio-server/license.lic
    chmod 600 /var/lib/rstudio-server/license.lic
elif ls /var/lib/rstudio-server/*.lic >/dev/null 2>&1; then
    echo "Detected a license file in /var/lib/rstudio-server/*.lic."
fi

# ensure these cannot be inherited by child processes
unset RSP_LICENSE
unset RSP_LICENSE_SERVER
unset RSW_LICENSE
unset RSW_LICENSE_SERVER
unset RSW_LICENSE_FILE_PATH

# Create one user
if [ $(getent passwd $RSW_TESTUSER_UID) ] ; then
    echo "UID $RSW_TESTUSER_UID already exists, not creating $RSW_TESTUSER test user";
else
    if [ -z "$RSW_TESTUSER" ]; then
        echo "Empty 'RSW_TESTUSER' variables, not creating test user";
    else
        if [ -z "$RSW_TESTUSER_UID" ]; then
            RSW_TESTUSER_UID=10000
        fi
        useradd -m -s /bin/bash -u $RSW_TESTUSER_UID -U $RSW_TESTUSER
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
