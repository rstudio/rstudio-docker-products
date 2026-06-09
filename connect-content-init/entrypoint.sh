#!/usr/bin/env bash

set -e

echo "WARNING: This image is deprecated and will reach end-of-life at the end of 2026." >&2
echo "Migrate to the new image: https://github.com/posit-dev/images-connect/blob/main/connect-content-init/README.md" >&2

set -x

S=/opt/rstudio-connect-runtime

# The target should exist and be an empty directory.
T=/mnt/rstudio-connect-runtime

if [ ! -d "${T}" ] ; then
    echo "Cannot find the copy target ${T}"
    exit 1
fi

echo "Copying RStudio Connect runtime ..."

for d in ext python R scripts nodejs ; do
    echo copying $S/$d to $T/$d
    cp -va $S/$d $T/$d
done

echo "Done copying RStudio Connect runtime."
