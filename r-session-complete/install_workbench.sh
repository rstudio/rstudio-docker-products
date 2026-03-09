#!/bin/bash
set -euo pipefail

# Output delimiter
d="===="
package_name="rstudio-server"

# Update apt repositories
apt-get update -yq

RSW_VERSION_URL=$(echo -n "${RSW_VERSION}" | sed 's/+/-/g')
deb_file="/tmp/rstudio-server.deb"
echo "$d Fetching Posit Workbench ${RSW_VERSION} $d"
curl -fsSL -o "$deb_file" "${RSW_DOWNLOAD_URL}/${RSW_NAME}-${RSW_VERSION_URL}-amd64.deb"
# Post 7/25 packages
gpg --keyserver hkps://keys.openpgp.org:443 --recv-keys 51C0B5BB19F92D60
dpkg-sig --verify "$deb_file"

# Install dependencies
dep_spec="$(dpkg-deb -f "$deb_file" Pre-Depends)"
depends="$(dpkg-deb -f "$deb_file" Depends)"
if [ -n "$dep_spec" ] && [ -n "$depends" ]; then
  dep_spec="${dep_spec}, ${depends}"
elif [ -z "$dep_spec" ]; then
  dep_spec="${depends}"
fi
apt-get satisfy -yq "$dep_spec"

# Patch the installer to not activate the service
echo "$d Patching ${deb_file} $d"
dpkg --unpack "${deb_file}"
sed -i 's/^rstudio-server force-suspend-all/# rstudio-server force-suspend-all/' /var/lib/dpkg/info/rstudio-server.postinst
sed -i 's/systemctl enable rstudio-server.service/# systemctl enable rstudio-server.service/g' /var/lib/dpkg/info/rstudio-server.postinst
sed -i 's/systemctl enable rstudio-launcher.service/# systemctl enable rstudio-launcher.service/g' /var/lib/dpkg/info/rstudio-server.postinst
awk '/if test "\$RSTUDIO_INSTALL_NO_LICENSE_INITIALIZATION" != "1"/ { skip=1 }
    skip { if (/fi/) { skip=0 } next }
    { print }
' "/var/lib/dpkg/info/rstudio-server.postinst" > "/var/lib/dpkg/info/rstudio-server.postinst.tmp"
install -m 755 "/var/lib/dpkg/info/rstudio-server.postinst.tmp" "/var/lib/dpkg/info/rstudio-server.postinst"
rm -f "/var/lib/dpkg/info/rstudio-server.postinst.tmp"

# Install Workbench
echo "$d Install Posit Workbench ${RSW_VERSION} $d"
dpkg --configure "${package_name}"
apt-get install -yf
rm -f "${deb_file}"

# Clean up
apt-get clean -yqq && \
rm -rf /var/lib/apt/lists/*
