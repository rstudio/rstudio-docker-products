#!/usr/bin/env bash

set -e
set -x

S=/opt/rstudio-connect-runtime

# The target should exist and be an empty directory.
T=/mnt/rstudio-connect-runtime

if [ ! -d "${T}" ] ; then
    echo "Cannot find the copy target ${T}"
    exit 1
fi

echo "Copying RStudio Connect runtime ..."

for d in ext python R scripts ; do
    echo copying $S/$d to $T/$d
    cp -va $S/$d $T/$d
done

echo "Done copying RStudio Connect runtime."
