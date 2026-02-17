#!/bin/bash

# install goss
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

# detect architecture
case $(uname -m) in
  x86_64)  GOSS_ARCH="amd64" ;;
  aarch64) GOSS_ARCH="arm64" ;;
  *)       echo "Unsupported architecture: $(uname -m)"; exit 1 ;;
esac

# install goss to tmp location and make executable
curl -fsSL "https://github.com/aelsabbahy/goss/releases/download/v${GOSS_VERSION}/goss-linux-${GOSS_ARCH}" -o /tmp/goss \
  && chmod +x /tmp/goss \
  && GOSS=/tmp/goss

OS=$OS GOSS_FILE=$GOSS_FILE $GOSS v --format documentation --max-concurrent $GOSS_MAX_CONCURRENT
