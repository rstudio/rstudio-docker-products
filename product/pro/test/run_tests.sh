#!/bin/bash

# start connect
trap 'err=$?; echo >&2 "run_tests.sh encountered an error: $err"; cat /tmp/startup.log; exit $err' ERR

echo '--> Startup complete'

GOSS_FILE=${GOSS_FILE:-/test/goss.yaml}
GOSS_VERSION=${GOSS_VERSION:-0.4.6}
GOSS_MAX_CONCURRENT=${GOSS_MAX_CONCURRENT:-50}

if [ -f /etc/debian_version ]; then
  OS="ubuntu"
elif [ -f /etc/centos-release ]; then
  OS="centos"
else
  echo "OS not supported. Exiting"
  exit 1
fi

# install goss to tmp location and make executable
curl -sL https://github.com/aelsabbahy/goss/releases/download/v$GOSS_VERSION/goss-linux-amd64 -o /tmp/goss \
  && chmod +x /tmp/goss \
  && GOSS=/tmp/goss

OS=$OS GOSS_FILE=$GOSS_FILE $GOSS v --format documentation --max-concurrent $GOSS_MAX_CONCURRENT
