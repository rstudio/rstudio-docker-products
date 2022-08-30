set positional-arguments

vars := "-i ''"

sed_vars := if os() == "macos" { "-i ''" } else { "-i" }

BUILDX_PATH := ""

RSW_VERSION := "2022.07.1+554.pro3"
RSW_TAG_VERSION := replace(RSW_VERSION, "+", "-")
RSC_VERSION := "2022.08.1"
RSPM_VERSION := "2022.07.2-11"
R_VERSION := "3.6.2"
R_VERSION_ALT := "4.1.0"

PYTHON_VERSION := "3.9.5"
PYTHON_VERSION_ALT := "3.8.10"

# just RSW_VERSION=1.2.3 update-versions
update-versions:
  just \
    RSW_VERSION={{RSW_VERSION}} RSC_VERSION={{RSC_VERSION}} RSPM_VERSION={{RSPM_VERSION}} \
    R_VERSION={{R_VERSION}} R_VERSION_ALT={{R_VERSION_ALT}} \
    update-rsw-versions update-rspm-versions update-rsc-versions update-r-versions

# just RSW_VERSION=1.2.3 update-rsw-versions
update-rsw-versions:
  #!/usr/bin/env bash
  set -euxo pipefail
  sed {{ sed_vars }} "s/^RSW_VERSION=.*/RSW_VERSION={{ RSW_VERSION }}/g" workbench/.env
  sed {{ sed_vars }} "s/^RSW_VERSION=.*/RSW_VERSION={{ RSW_VERSION }}/g" r-session-complete/.env
  sed {{ sed_vars }} "s/^ARG RSW_VERSION=.*/ARG RSW_VERSION={{ RSW_VERSION }}/g" r-session-complete/Dockerfile.bionic
  sed {{ sed_vars }} "s/^ARG RSW_VERSION=.*/ARG RSW_VERSION={{ RSW_VERSION }}/g" r-session-complete/Dockerfile.centos7
  sed {{ sed_vars }} "s/^ARG RSW_VERSION=.*/ARG RSW_VERSION={{ RSW_VERSION }}/g" workbench/Dockerfile.bionic
  sed {{ sed_vars }} "s/RSW_VERSION:.*/RSW_VERSION: {{ RSW_VERSION }}/g" docker-compose.yml
  sed {{ sed_vars }} "s/rstudio\/rstudio-workbench:.*/rstudio\/rstudio-workbench:{{ RSW_TAG_VERSION }}/g" docker-compose.yml
  sed {{ sed_vars }} "s/^ARG RSW_VERSION=.*/ARG RSW_VERSION={{ RSW_VERSION }}/g" workbench-for-microsoft-azure-ml/Dockerfile.bionic
  sed {{ sed_vars }} "s/org.opencontainers.image.version='.*'/org.opencontainers.image.version='{{ RSW_VERSION }}'/g" workbench-for-microsoft-azure-ml/Dockerfile.bionic

# just RSPM_VERSION=1.2.3 update-rspm-versions
update-rspm-versions:
  #!/usr/bin/env bash
  set -euxo pipefail
  sed {{ sed_vars }} "s/^RSPM_VERSION=.*/RSPM_VERSION={{ RSPM_VERSION }}/g" package-manager/.env
  sed {{ sed_vars }} "s/^ARG RSPM_VERSION=.*/ARG RSPM_VERSION={{ RSPM_VERSION }}/g" package-manager/Dockerfile.bionic
  sed {{ sed_vars }} "s/^RSPM_VERSION:.*/RSPM_VERSION: {{ RSPM_VERSION }}/g" docker-compose.yml
  sed {{ sed_vars }} "s/RSPM_VERSION:.*/RSPM_VERSION: {{ RSPM_VERSION }}/g" docker-compose.yml
  sed {{ sed_vars }} "s/rstudio\/rstudio-package-manager:.*/rstudio\/rstudio-package-manager:{{ RSPM_VERSION }}/g" docker-compose.yml

# just RSC_VERSION=1.2.3 update-rsc-versions
update-rsc-versions:
  #!/usr/bin/env bash
  set -euxo pipefail
  sed {{ sed_vars }} "s/^RSC_VERSION=.*/RSC_VERSION={{ RSC_VERSION }}/g" connect/.env
  sed {{ sed_vars }} "s/^ARG RSC_VERSION=.*/ARG RSC_VERSION={{ RSC_VERSION }}/g" connect/Dockerfile.bionic
  sed {{ sed_vars }} "s/^ARG RSC_VERSION=.*/ARG RSC_VERSION={{ RSC_VERSION }}/g" connect-content-init/Dockerfile.bionic
  sed {{ sed_vars }} "s/RSC_VERSION:.*/RSC_VERSION: {{ RSC_VERSION }}/g" docker-compose.yml
  sed {{ sed_vars }} "s/rstudio\/rstudio-connect:.*/rstudio\/rstudio-connect:{{ RSC_VERSION }}/g" docker-compose.yml
  sed {{ sed_vars }} "s/^RSC_VERSION?=.*/RSC_VERSION?={{ RSC_VERSION }}/g" connect-content-init/Makefile

# just R_VERSION=3.2.1 update-r-versions
update-r-versions:
  #!/usr/bin/env bash
  set -euxo pipefail
  sed {{ sed_vars }} "s/^R_VERSION:.*/R_VERSION={{ R_VERSION }}/g" workbench/Dockerfile.bionic
  sed {{ sed_vars }} "s/^R_VERSION:.*/R_VERSION={{ R_VERSION }}/g" connect/Dockerfile.bionic
  sed {{ sed_vars }} "s/^R_VERSION:.*/R_VERSION={{ R_VERSION }}/g" package-manager/Dockerfile.bionic
  sed {{ sed_vars }} "s|^RVersion.*=.*|RVersion = /opt/R/{{ R_VERSION }}/|g" package-manager/rstudio-pm.gcfg

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

_rsw-download-url TYPE $OS:
  #!/usr/bin/env bash
  if [[ "$OS" == "rockylinux8" || "$OS" == "centos7" || "$OS" == "centos8" ]]; then
    ARCH="x86_64"
  else
    ARCH="amd64"
  fi

  if [[ "$OS" == "rockylinux8" || "$OS" == "centos8" ]]; then
    OS="rhel8"
  fi

  if [[ "{{TYPE}}" == "release" ]]; then
    echo "https://download2.rstudio.org/server/$OS/$ARCH"
  else
    echo "https://s3.amazonaws.com/rstudio-ide-build/server/$OS/$ARCH"
  fi

# just push-images tag1 tag2 ...
push-images +IMAGES:
  #!/usr/bin/env bash
  set -euxo pipefail
  for IMAGE in {{IMAGES}}
  do
    docker push $IMAGE
  done

# just test-image preview workbench 12.0.11-8 tag1 tag2 tag3 ...
test-image $PRODUCT $VERSION +IMAGES:
  #!/usr/bin/env bash
  set -euxo pipefail
  IMAGES="{{IMAGES}}"
  read -ra IMAGE_ARRAY <<<"$IMAGES"
  cd ./"$PRODUCT" && \
    IMAGE_NAME="${IMAGE_ARRAY[0]}" RSW_VERSION="$VERSION" RSC_VERSION="$VERSION" RSPM_VERSION="$VERSION" \
    docker-compose -f docker-compose.test.yml run sut

# just get-version workbench --type=preview --local
get-version +NARGS:
  ./get-version.py {{NARGS}}

_tag_safe_version $VERSION:
  #!/usr/bin/env bash
  echo -n "$VERSION" | sed 's/+/-/g'

lint $PRODUCT $OS:
  #!/usr/bin/env bash
  docker run --rm -i -v $PWD/hadolint.yaml:/.config/hadolint.yaml ghcr.io/hadolint/hadolint < $PRODUCT/Dockerfile.$OS
