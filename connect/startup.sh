#!/bin/bash

set -e
if [[ "${STARTUP_DEBUG_MODE:-0}" -eq 1 ]]; then
  set -x
fi

# Deactivate license when it exists
deactivate() {
    echo "Deactivating license ..."
    is_deactivated=0
    retries=0
    while [[ $is_deactivated -ne 1 ]] && [[ $retries -le 3 ]]; do
      /opt/rstudio-connect/bin/license-manager deactivate >/dev/null 2>&1
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

# Activate License
RSC_LICENSE_FILE_PATH=${RSC_LICENSE_FILE_PATH:-/etc/rstudio-connect/license.lic}
if ! [ -z "$RSC_LICENSE" ]; then
    /opt/rstudio-connect/bin/license-manager activate $RSC_LICENSE
    trap deactivate EXIT
elif ! [ -z "$RSC_LICENSE_SERVER" ]; then
    /opt/rstudio-connect/bin/license-manager license-server $RSC_LICENSE_SERVER
    trap deactivate EXIT
elif test -f "$RSC_LICENSE_FILE_PATH"; then
    rm -f /var/lib/rstudio-connect/*.lic
    cp "${RSC_LICENSE_FILE_PATH}" /var/lib/rstudio-connect/license.lic
    chmod g-rwx,g-rwx /var/lib/rstudio-connect/license.lic
elif ls /var/lib/rstudio-connect/*.lic >/dev/null 2>&1; then
    echo "Detected a license file in /var/lib/rstudio-connect/*.lic."
fi

# ensure these cannot be inherited by child processes
unset RSC_LICENSE
unset RSC_LICENSE_SERVER
unset RSC_LICENSE_FILE_PATH

# Start RStudio Connect
/opt/rstudio-connect/bin/connect --config /etc/rstudio-connect/rstudio-connect.gcfg
