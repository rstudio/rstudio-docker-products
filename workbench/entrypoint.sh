#!/bin/bash
set -euo pipefail

# Bundled SSSD is a root-only provisioning daemon. Install its supervisord
# program only when running as root and not disabled. Skips cleanly when
# non-root (rootless) or when something already supplies one (e.g. a mounted
# Helm-rendered program), so it never lands a non-root sssd that would FATAL
# and take down the container via the process-monitor eventlistener.
if [ "$(id -u)" -eq 0 ] && [ "${RSW_SSSD:-true}" = "true" ] \
   && [ -w /startup/user-provisioning ] && [ ! -e /startup/user-provisioning/sssd.conf ]; then
  install -m 0644 /opt/startup-templates/sssd.conf /startup/user-provisioning/sssd.conf
fi

exec "$@"
