#!/bin/bash
set -xe

RSW_TIMEOUT=${RSW_TIMEOUT:-15}

touch /tmp/startup.log
trap 'err=$?; echo >&2 "run_tests.sh encountered an error: $err"; cat /tmp/startup.log; exit $err' ERR

# start rstudio-server
echo "--> Starting RStudio Workbench"
/usr/bin/supervisord -c /etc/supervisor/supervisord.conf > /tmp/startup.log 2>&1 &
sleep 15

echo "--> Waiting for workbench to startup... with RSW_TIMEOUT: $RSW_TIMEOUT"
wait-for-it.sh localhost:8787 -t $RSW_TIMEOUT
wait-for-it.sh localhost:5559 -t $RSW_TIMEOUT
echo "--> Startup complete"

GOSS_FILE=${GOSS_FILE:-/tmp/test/goss.yaml}
GOSS_VERSION=${GOSS_VERSION:-0.4.6}
GOSS_MAX_CONCURRENT=${GOSS_MAX_CONCURRENT:-5}

# install goss to tmp location and make executable
curl -sL https://github.com/aelsabbahy/goss/releases/download/v$GOSS_VERSION/goss-linux-amd64 -o /tmp/goss \
  && chmod +x /tmp/goss \
  && GOSS=/tmp/goss

GOSS_FILE=$GOSS_FILE $GOSS v --format documentation --max-concurrent $GOSS_MAX_CONCURRENT
