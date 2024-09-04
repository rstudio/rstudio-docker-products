#!/bin/bash
set -xe

RSW_TIMEOUT=${RSW_TIMEOUT:-60}

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

if [ -f /etc/debian_version ]; then
  OS="ubuntu"
elif [ -f /etc/centos-release ]; then
  OS="centos"
else
  echo "OS not supported. Exiting"
  exit 1
fi

GOSS_FILE=${GOSS_FILE:-/test/goss.yaml}
GOSS_VARS_FILE=${GOSS_VARS_FILE:-/test/goss_vars.yaml}
GOSS_VERSION=${GOSS_VERSION:-0.4.6}
GOSS_MAX_CONCURRENT=${GOSS_MAX_CONCURRENT:-5}

# install goss to tmp location and make executable
curl -fsSL https://github.com/aelsabbahy/goss/releases/download/v$GOSS_VERSION/goss-linux-amd64 -o /tmp/goss \
  && chmod +x /tmp/goss \
  && GOSS=/tmp/goss

OS=$OS GOSS_FILE=$GOSS_FILE GOSS_VARS=$GOSS_VARS_FILE $GOSS v --format documentation --max-concurrent $GOSS_MAX_CONCURRENT
