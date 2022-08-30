#!/usr/bin/env bash
IMAGES=$(just build-release $1 $2 $(just get-version $1 --type=release --local))
just test-image $1 $(just get-version $1 --type=release --local) $IMAGES