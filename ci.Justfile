set positional-arguments

BUILDX_PATH := ""
REGISTRY_NAMESPACE := "rstudio"

R_VERSION := "4.2.3"
R_VERSION_ALT := "4.1.3"

PYTHON_VERSION := "3.9.17"
PYTHON_VERSION_ALT := "3.8.17"

DRIVERS_VERSION := "2025.07.0"
DRIVERS_VERSION_RHEL := DRIVERS_VERSION + "-1"

QUARTO_VERSION := "1.4.557"

# just _get-os-alias jammy
_get-os-alias OS:
  #!/usr/bin/env bash
  if [[ "{{OS}}" == "bionic" || "{{OS}}" == "ubuntu1804" ]]; then
    echo "ubuntu1804 bionic"
  elif [[ "{{OS}}" == "jammy" || "{{OS}}" == "ubuntu2204" ]]; then
    echo "ubuntu2204 jammy"
  else
    echo "{{OS}}"
  fi

# just _get-default-tag connect ubuntu2204
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

# just _get-rsw-download-url release ubuntu2204
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
