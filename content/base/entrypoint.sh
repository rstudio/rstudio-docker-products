#!/bin/bash
set -e

echo "WARNING: Posit will stop publishing this image at the end of 2026." >&2
echo "Migrate to the new image: https://github.com/posit-dev/images-connect/blob/main/connect-content/README.md" >&2

if [ "$#" -eq 0 ]; then
  echo "No command specified" >&2
  exit 1
fi
exec "$@"
