#!/usr/bin/env bash
MATRIX_RAW=`just gm --types preview --os bionic jammy --packages workbench connect package-manager | jq -Mcr`
echo $MATRIX_RAW