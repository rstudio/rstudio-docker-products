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
      /opt/rstudio-pm/bin/license-manager deactivate --userspace >/dev/null 2>&1
      is_deactivated=1
      ((retries+=1))
      for file in $(ls -A /home/rstudio-pm/.local); do
        if [ -s /home/rstudio-pm/.local/$file ]; then
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

# Activate License
RSPM_LICENSE_FILE_PATH=${RSPM_LICENSE_FILE_PATH:-/etc/rstudio-pm/license.lic}
/opt/rstudio-pm/bin/license-manager initialize --userspace || true
if ! [ -z "$RSPM_LICENSE" ]; then
    /opt/rstudio-pm/bin/license-manager activate $RSPM_LICENSE --userspace
elif ! [ -z "$RSPM_LICENSE_SERVER" ]; then
    /opt/rstudio-pm/bin/license-manager license-server $RSPM_LICENSE_SERVER --userspace
elif test -f "${RSPM_LICENSE_FILE_PATH}"; then
    mkdir -p /home/rstudio-pm/.rstudio-pm
    cp "${RSPM_LICENSE_FILE_PATH}" /home/rstudio-pm/.rstudio-pm/license.lic
    chown rstudio-pm /home/rstudio-pm/.rstudio-pm/license.lic
    chmod 0600 /home/rstudio-pm/.rstudio-pm/license.lic
elif ls /var/lib/rstudio-pm/*.lic >/dev/null 2>&1; then
    echo "Detected a license file in /var/lib/rstudio-pm/*.lic."
elif ls /home/rstudio-pm/.rstudio-pm/*.lic >/dev/null 2>&1; then
    echo "Detected a license file in /home/rstudio-pm/.rstudio-pm/*.lic."
fi

# ensure these cannot be inherited by child processes
unset RSPM_LICENSE
unset RSPM_LICENSE_SERVER
unset RSPM_LICENSE_FILE_PATH

# Start RStudio Package Manager
/opt/rstudio-pm/bin/rstudio-pm --config /etc/rstudio-pm/rstudio-pm.gcfg
