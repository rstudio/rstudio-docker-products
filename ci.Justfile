set positional-arguments

BUILDX_PATH := ""
REGISTRY_NAMESPACE := "rstudio"

R_VERSION := "4.2.3"
R_VERSION_ALT := "4.1.3"

PYTHON_VERSION := "3.9.17"
PYTHON_VERSION_ALT := "3.8.17"

DRIVERS_VERSION := "2023.05.0"
DRIVERS_VERSION_RHEL := DRIVERS_VERSION + "-1"

QUARTO_VERSION := "1.3.340"

# just BUILDX_PATH=~/.buildx build-release workbench bionic 12.0.11-11
_get-os-alias OS:
  #!/usr/bin/env bash
  if [[ "{{OS}}" == "bionic" || "{{OS}}" == "ubuntu1804" ]]; then
    echo "ubuntu1804 bionic"
  elif [[ "{{OS}}" == "jammy" || "{{OS}}" == "ubuntu2204" ]]; then
    echo "ubuntu2204 jammy"
  else
    echo "{{OS}}"
  fi

_get-default-tag PRODUCT OS:
  #!/usr/bin/env bash
  set -euxo pipefail

  # set image prefix
  if [[ {{ PRODUCT }} == "r-session-complete" ]]; then
    IMAGE_PREFIX=""
  else
    IMAGE_PREFIX="rstudio-"
  fi

  echo "{{ REGISTRY_NAMESPACE }}/${IMAGE_PREFIX}{{ PRODUCT }}:{{ OS }}"

get-base-args $OS $TYPE="base" $BRANCH=`git branch --show`:
  #!/usr/bin/env bash
  set -euxo pipefail
  if [[ $TYPE == "base" || $TYPE == "product-base" ]]; then
    SRC_IMAGE_NAME=""
    CTX_PATH="./product/base"
    FILE_PATH="./product/base/Dockerfile.${OS}"
  elif [[ $TYPE == "base-pro" || $TYPE == "pro" || $TYPE == "product-base-pro" ]]; then
    SRC_IMAGE_NAME="product-base"
    CTX_PATH="./product/pro"
    FILE_PATH="./product/pro/Dockerfile.${OS}"
  fi
  if [[ $BRANCH != "main" ]]; then
    SRC_IMAGE_NAME="${SRC_IMAGE_NAME}-dev"
  fi

  if [[ "${OS}" == "centos7" ]]; then
    _DRIVERS_VERSION="{{ DRIVERS_VERSION_RHEL }}"
  else
    _DRIVERS_VERSION="{{ DRIVERS_VERSION }}"
  fi

  printf "R_VERSION={{ R_VERSION }}
  R_VERSION_ALT={{ R_VERSION_ALT }}
  PYTHON_VERSION={{ PYTHON_VERSION }}
  PYTHON_VERSION_ALT={{ PYTHON_VERSION_ALT }}
  QUARTO_VERSION={{ QUARTO_VERSION }}
  DRIVERS_VERSION=${_DRIVERS_VERSION}
  SRC_IMAGE_NAME=${SRC_IMAGE_NAME}"

get-base-tags $OS $TYPE="base" $BRANCH=`git branch --show`:
  #!/usr/bin/env bash
  set -euxo pipefail
  IMAGE_NAME=""
  if [[ $TYPE == "base" || $TYPE == "product-base" ]]; then
    IMAGE_NAME="product-base"
  elif [[ $TYPE == "base-pro" || $TYPE == "pro" || $TYPE == "product-base-pro" ]]; then
    IMAGE_NAME="product-base-pro"
  fi
  if [[ $BRANCH != "main" ]]; then
    IMAGE_NAME="${IMAGE_NAME}-dev"
  fi

  echo ghcr.io/rstudio/${IMAGE_NAME}:${OS},\
  ghcr.io/rstudio/${IMAGE_NAME}:${OS}-r{{R_VERSION}}-py{{PYTHON_VERSION}},\
  ghcr.io/rstudio/${IMAGE_NAME}:${OS}-r{{R_VERSION}}_{{R_VERSION_ALT}}-py{{PYTHON_VERSION}}_{{PYTHON_VERSION_ALT}}

get-product-args $PRODUCT $OS $VERSION $BRANCH=`git branch --show` $SHA_SHORT=`git rev-parse --short HEAD`:
  #!/usr/bin/env bash
  set -euxo pipefail
  RSW_DOWNLOAD_URL=$(just -f ci.Justfile _get-rsw-download-url release $OS)

  # set source image name
  SRC_IMAGE_NAME=""
  if [[ $PRODUCT == "workbench" || $PRODUCT == "r-session-complete" || $PRODUCT == "workbench-for-microsoft-azure-ml" || $PRODUCT == "connect" ]]; then
    if [[ $BRANCH == "main" ]]; then
      SRC_IMAGE_NAME="product-base-pro"
    else
      SRC_IMAGE_NAME="product-base-pro-dev"
    fi
  fi

  printf "R_VERSION={{ R_VERSION }}
  R_VERSION_ALT={{ R_VERSION_ALT }}
  PYTHON_VERSION={{ PYTHON_VERSION }}
  PYTHON_VERSION_ALT={{ PYTHON_VERSION_ALT }}
  QUARTO_VERSION={{ QUARTO_VERSION }}
  DRIVERS_VERSION=${_DRIVERS_VERSION}
  SRC_IMAGE_NAME=${SRC_IMAGE_NAME}
  RSW_DOWNLOAD_URL=${RSW_DOWNLOAD_URL}"

get-product-tags $PRODUCT $OS $VERSION $BRANCH=`git branch --show` $SHA_SHORT=`git rev-parse --short HEAD`:
  #!/usr/bin/env bash
  set -euxo pipefail

  # variable placeholders
  SHORT_NAME=""
  TAG_CLEAN_VERSION=$(just _get-clean-version $VERSION)

  # set short name and source image name
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

  read -a OS_ALIASES <<< $(just -f {{justfile()}} _get-os-alias ${OS})
  tag_array=()
  for os_name in ${OS_ALIASES[@]};
  do
    tag_array+=(
      "rstudio/${IMAGE_PREFIX}${PRODUCT}:${os_name}"
      "rstudio/${IMAGE_PREFIX}${PRODUCT}:${os_name}-${TAG_CLEAN_VERSION}"
      "rstudio/${IMAGE_PREFIX}${PRODUCT}:${os_name}-${TAG_CLEAN_VERSION}--${SHA_SHORT}"
      "ghcr.io/rstudio/${IMAGE_PREFIX}${PRODUCT}:${os_name}"
      "ghcr.io/rstudio/${IMAGE_PREFIX}${PRODUCT}:${os_name}-${TAG_CLEAN_VERSION}"
      "ghcr.io/rstudio/${IMAGE_PREFIX}${PRODUCT}:${os_name}-${TAG_CLEAN_VERSION}--${SHA_SHORT}"
    )
  done
  tags=$(IFS="," ; echo "${tag_array[*]}")
  echo "${tags}"

# just BUILDX_PATH=~/.buildx build-preview preview workbench ubuntu1804 12.0.11-11
build-preview $TYPE $PRODUCT $OS $VERSION $BRANCH=`git branch --show`:
  #!/usr/bin/env bash
  set -euxo pipefail

  # variable placeholders
  BRANCH_PREFIX=""
  RSW_DOWNLOAD_URL=`just -f ci.Justfile _get-rsw-download-url $TYPE $OS`
  BUILDX_ARGS=""
  SHORT_NAME=""
  TAG_CLEAN_VERSION=`just _get-clean-version $VERSION`
  TAG_VERSION=`just _get-tag-safe-version $VERSION`

  # set branch prefix
  if [[ $BRANCH == "dev" ]]; then
    BRANCH_PREFIX="dev-"
  elif [[ $BRANCH == "dev-rspm" ]]; then
    BRANCH_PREFIX="dev-rspm-"
  fi

  # set short name
  SRC_IMAGE_NAME=""
  if [[ $PRODUCT == "workbench" || $PRODUCT == "r-session-complete" || $PRODUCT == "workbench-for-microsoft-azure-ml" ]]; then
    SHORT_NAME="RSW"
    if [[ $BRANCH == "main" ]]; then
      SRC_IMAGE_NAME="product-base-pro"
    else
      SRC_IMAGE_NAME="product-base-pro-dev"
    fi
  elif [[ $PRODUCT == "connect" || $PRODUCT == "connect-content-init" ]]; then
    SHORT_NAME="RSC"
    if [[ $BRANCH == "main" ]]; then
      SRC_IMAGE_NAME="product-base"
    else
      SRC_IMAGE_NAME="product-base-dev"
    fi
  elif [[ $PRODUCT == "package-manager" ]]; then
    SHORT_NAME="RSPM"
  fi

  # set image prefix
  if [[ $PRODUCT == "r-session-complete" ]]; then
    IMAGE_PREFIX=""
  else
    IMAGE_PREFIX="rstudio-"
  fi

  read -a OS_ALIASES <<< $(just -f {{justfile()}} _get-os-alias ${OS})
  tag_array=()
  for os_name in ${OS_ALIASES[@]};
  do
    tag_array+=(
      "-t" "rstudio/${IMAGE_PREFIX}${PRODUCT}-preview:${BRANCH_PREFIX}${os_name}-${TAG_VERSION}"
      "-t" "rstudio/${IMAGE_PREFIX}${PRODUCT}-preview:${BRANCH_PREFIX}${os_name}-${TAG_CLEAN_VERSION}"
      "-t" "rstudio/${IMAGE_PREFIX}${PRODUCT}-preview:${BRANCH_PREFIX}${os_name}-${TYPE}"
      "-t" "ghcr.io/rstudio/${IMAGE_PREFIX}${PRODUCT}-preview:${BRANCH_PREFIX}${os_name}-${TAG_VERSION}"
      "-t" "ghcr.io/rstudio/${IMAGE_PREFIX}${PRODUCT}-preview:${BRANCH_PREFIX}${os_name}-${TAG_CLEAN_VERSION}"
      "-t" "ghcr.io/rstudio/${IMAGE_PREFIX}${PRODUCT}-preview:${BRANCH_PREFIX}${os_name}-${TYPE}"
    )
  done

  # set buildx args
  if [[ "{{BUILDX_PATH}}" != "" ]]; then
    BUILDX_ARGS="--cache-from=type=local,src=/tmp/.buildx-cache --cache-to=type=local,dest=/tmp/.buildx-cache"
  fi

  docker buildx --builder="{{BUILDX_PATH}}" build --load $BUILDX_ARGS \
        ${tag_array[@]} \
        --build-arg ${SHORT_NAME}_VERSION=$VERSION \
        --build-arg RSW_DOWNLOAD_URL=$RSW_DOWNLOAD_URL \
        --build-arg R_VERSION="{{ R_VERSION }}" \
        --build-arg R_VERSION_ALT="{{ R_VERSION_ALT }}" \
        --build-arg PYTHON_VERSION="{{ PYTHON_VERSION }}" \
        --build-arg PYTHON_VERSION_ALT="{{ PYTHON_VERSION_ALT }}" \
        --build-arg SRC_IMAGE_NAME="${SRC_IMAGE_NAME}" \
        --file=./${PRODUCT}/Dockerfile.$(just _parse-os ${OS}) ${PRODUCT}

  # These tags are propogated forward to test-images and push-images in builds. It is important that these tags match the build tags above.
  echo ${tag_array[*]//-t/}

# just push-images tag1 tag2 ...
push-images +IMAGES:
  #!/usr/bin/env bash
  set -euxo pipefail
  for IMAGE in {{IMAGES}}
  do
    docker push $IMAGE
  done

# just _get-rsw-download-url release ubuntu1804
_get-rsw-download-url TYPE OS:
  #!/usr/bin/env bash
  URL_OS="{{OS}}"
  if [[ "{{OS}}" == "ubuntu1804" ]]; then
    URL_OS="bionic"
  elif [[ "{{OS}}" == "ubuntu2204" ]]; then
    URL_OS="jammy"
  fi

  if [[ "{{TYPE}}" == "release" ]]; then
    echo "https://download2.rstudio.org/server/${URL_OS}/{{ if OS == "centos7" { "x86_64"} else { "amd64" } }}"
  else
    echo "https://s3.amazonaws.com/rstudio-ide-build/server/${URL_OS}/{{ if OS == "centos7" { "x86_64"} else { "amd64" } }}"
  fi

# just get-version workbench --type=preview --local
get-version +NARGS:
  ./tools/get-version.py {{NARGS}}
