set positional-arguments

build-release $PRODUCT $OS $VERSION $BRANCH=`git branch --show` $SHA_SHORT=`git rev-parse --short HEAD`:
  #!/usr/bin/env bash
  set -euxo pipefail

  # variable placeholders
  RSW_DOWNLOAD_URL=`just _rsw-download-url release $OS`
  BUILDX_ARGS=""
  SHORT_NAME=""
  TAG_VERSION=`just _tag_safe_version $VERSION`

  # set short name
  if [[ $PRODUCT == "workbench" || $PRODUCT == "r-session-complete" || $PRODUCT == "workbench-for-microsoft-azure-ml" ]]; then
    SHORT_NAME="RSW"
  elif [[ $PRODUCT == "connect" ]]; then
    SHORT_NAME="RSC"
  elif [[ $PRODUCT == "package-manager" ]]; then
    SHORT_NAME="RSPM"
  fi

  # set image prefix
  if [[ $PRODUCT == "r-session-complete" ]]; then
    IMAGE_PREFIX=""
  else
    IMAGE_PREFIX="rstudio-"
  fi

  # set buildx args
  if [[ "{{BUILDX_PATH}}" != "" ]]; then
    BUILDX_ARGS="--cache-from=type=local,src=/tmp/.buildx-cache --cache-to=type=local,dest=/tmp/.buildx-cache"
  fi

  docker buildx --builder="{{BUILDX_PATH}}" build --load $BUILDX_ARGS \
        -t rstudio/${IMAGE_PREFIX}${PRODUCT}:${OS} \
        -t rstudio/${IMAGE_PREFIX}${PRODUCT}:${OS}-${TAG_VERSION} \
        -t rstudio/${IMAGE_PREFIX}${PRODUCT}:${OS}-${TAG_VERSION}--${SHA_SHORT} \
        -t ghcr.io/rstudio/${IMAGE_PREFIX}${PRODUCT}:${OS} \
        -t ghcr.io/rstudio/${IMAGE_PREFIX}${PRODUCT}:${OS}-${TAG_VERSION} \
        -t ghcr.io/rstudio/${IMAGE_PREFIX}${PRODUCT}:${OS}-${TAG_VERSION}--${SHA_SHORT} \
        --build-arg "$SHORT_NAME"_VERSION=$VERSION \
        --build-arg RSW_DOWNLOAD_URL=$RSW_DOWNLOAD_URL \
        --file=./${PRODUCT}/Dockerfile.${OS} ${PRODUCT}

  echo rstudio/${IMAGE_PREFIX}${PRODUCT}:${OS} \
        rstudio/${IMAGE_PREFIX}${PRODUCT}:${OS}-${TAG_VERSION} \
        rstudio/${IMAGE_PREFIX}${PRODUCT}:${OS}-${TAG_VERSION}--${SHA_SHORT} \
        ghcr.io/rstudio/${IMAGE_PREFIX}${PRODUCT}:${OS} \
        ghcr.io/rstudio/${IMAGE_PREFIX}${PRODUCT}:${OS}-${TAG_VERSION} \
        ghcr.io/rstudio/${IMAGE_PREFIX}${PRODUCT}:${OS}-${TAG_VERSION}--${SHA_SHORT}

# just BUILDX_PATH=~/.buildx build-preview preview workbench bionic 12.0.11-11
build-preview $TYPE $PRODUCT $OS $VERSION $BRANCH=`git branch --show`:
  #!/usr/bin/env bash
  set -euxo pipefail

  # variable placeholders
  BRANCH_PREFIX=""
  RSW_DOWNLOAD_URL=`just _rsw-download-url $TYPE $OS`
  BUILDX_ARGS=""
  SHORT_NAME=""
  TAG_VERSION=`just _tag_safe_version $VERSION`

  # set branch prefix
  if [[ $BRANCH == "dev" ]]; then
    BRANCH_PREFIX="dev-"
  elif [[ $BRANCH == "dev-rspm" ]]; then
    BRANCH_PREFIX="dev-rspm-"
  fi

  # set short name
  if [[ $PRODUCT == "workbench" || $PRODUCT == "r-session-complete" || $PRODUCT == "workbench-for-microsoft-azure-ml" ]]; then
    SHORT_NAME="RSW"
  elif [[ $PRODUCT == "connect" || $PRODUCT == "connect-content-init" ]]; then
    SHORT_NAME="RSC"
  elif [[ $PRODUCT == "package-manager" ]]; then
    SHORT_NAME="RSPM"
  fi

  # set image prefix
  if [[ $PRODUCT == "r-session-complete" ]]; then
    IMAGE_PREFIX=""
  else
    IMAGE_PREFIX="rstudio-"
  fi

  # set buildx args
  if [[ "{{BUILDX_PATH}}" != "" ]]; then
    BUILDX_ARGS="--cache-from=type=local,src=/tmp/.buildx-cache --cache-to=type=local,dest=/tmp/.buildx-cache"
  fi

  docker buildx --builder="{{BUILDX_PATH}}" build --load $BUILDX_ARGS \
        -t rstudio/${IMAGE_PREFIX}${PRODUCT}-preview:${BRANCH_PREFIX}${OS}-${TAG_VERSION} \
        -t rstudio/${IMAGE_PREFIX}${PRODUCT}-preview:${BRANCH_PREFIX}${OS}-${TYPE} \
        -t ghcr.io/rstudio/${IMAGE_PREFIX}${PRODUCT}-preview:${BRANCH_PREFIX}${OS}-${TAG_VERSION} \
        -t ghcr.io/rstudio/${IMAGE_PREFIX}${PRODUCT}-preview:${BRANCH_PREFIX}${OS}-${TYPE} \
        --build-arg ${SHORT_NAME}_VERSION=$VERSION \
        --build-arg RSW_DOWNLOAD_URL=$RSW_DOWNLOAD_URL \
        --file=./${PRODUCT}/Dockerfile.${OS} ${PRODUCT}

  # These tags are propogated forward to test-images and push-images in builds. It is important that these tags match the build tags above.
  echo rstudio/${IMAGE_PREFIX}${PRODUCT}-preview:${BRANCH_PREFIX}${OS}-${TAG_VERSION} \
        rstudio/${IMAGE_PREFIX}${PRODUCT}-preview:${BRANCH_PREFIX}${OS}-${TYPE} \
        ghcr.io/rstudio/${IMAGE_PREFIX}${PRODUCT}-preview:${BRANCH_PREFIX}${OS}-${TAG_VERSION} \
        ghcr.io/rstudio/${IMAGE_PREFIX}${PRODUCT}-preview:${BRANCH_PREFIX}${OS}-${TYPE}

_rsw-download-url TYPE OS:
  #!/usr/bin/env bash
  if [[ "{{TYPE}}" == "release" ]]; then
    echo "https://download2.rstudio.org/server/{{OS}}/{{ if OS == "centos7" { "x86_64"} else { "amd64" } }}"
  else
    echo "https://s3.amazonaws.com/rstudio-ide-build/server/{{OS}}/{{ if OS == "centos7" { "x86_64"} else { "amd64" } }}"
  fi