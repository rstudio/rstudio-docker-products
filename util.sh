#!/usr/bin/env bash
IMAGES=$(just build-release $1 $2 $(just get-version $1 --type=release --override=$3))
just test-image $1 $(just get-version $1 --type=release --override=$3) $IMAGES