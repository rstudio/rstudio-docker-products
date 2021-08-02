#!/bin/bash

base_url=$1
filename=$2
version_and_suffix=$3
output_file=$4
args=$5

echo "Trying to find the rstudio-workbench installation binary..."

# it is ok to try all 3 channels in succession
# because versions are mutually exclusive
# so they can only live in one channel
# we prioritize the release channel, for safety
for c in "" "preview-" "daily-"; do

  # build URL
  url="${base_url}/${filename}-${c}${version_and_suffix}"
  echo "Trying URL: ${url}"

  # -f should tell us if it fails
  curl ${args} -f -o "$output_file" "${url}"
  res=$?
  if [ $res -gt 0 ]; then
    continue
  else
    echo "Success! Downloaded file ${output_file}"
    # success
    exit 0
  fi
done

# we should not get here
# if we do, we could not find the file
exit 2
