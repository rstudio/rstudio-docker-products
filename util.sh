#!/usr/bin/env bash
IMAGES=$(just build-release $1 $2 $(just get-version $1 --type=release))
just test-image $1 $(just get-version $1 --type=release) $IMAGES