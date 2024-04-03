#!/bin/bash

# install goss

GOSS_FILE=${GOSS_FILE:-/tmp/test/goss.yaml}
GOSS_VERSION=${GOSS_VERSION:-0.4.6}
GOSS_MAX_CONCURRENT=${GOSS_MAX_CONCURRENT:-50}

# install goss to tmp location and make executable
curl -sL https://github.com/aelsabbahy/goss/releases/download/v$GOSS_VERSION/goss-linux-amd64 -o /tmp/goss \
  && chmod +x /tmp/goss \
  && GOSS=/tmp/goss

GOSS_FILE=$GOSS_FILE $GOSS v --format documentation --max-concurrent $GOSS_MAX_CONCURRENT
