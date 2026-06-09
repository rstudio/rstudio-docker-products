#!/bin/bash
set -e

echo "WARNING: Posit will stop publishing this image at the end of 2026." >&2
echo "Switch to the new image: https://github.com/posit-dev/images-workbench/blob/main/workbench-positron-init/README.md" >&2

exec "$@"
