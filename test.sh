#!/usr/bin/env bash
docker buildx build --tag rstudio/testing \
	--build-arg RSW_VERSION=`just gv workbench --type=release --local` \
	--build-arg RSW_DOWNLOAD_URL=https://s3.amazonaws.com/rstudio-ide-build/server/bionic/x86_64 \
	--file=./workbench/docker/bionic/Dockerfile workbench