#!/usr/bin/env bash

set -euo pipefail
set -x

S=/opt/session-components

# The target should exist and be an empty directory.
T=/mnt/init

if [ ! -d "${T}" ] ; then
    echo "Cannot find the copy target ${T}"
    exit 1
fi

echo "Copying files from /session-components to /mnt/init"
time cp -r $S/* $T
