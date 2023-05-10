set positional-arguments

vars := "-i ''"

sed_vars := if os() == "macos" { "-i ''" } else { "-i" }

BUILDX_PATH := ""

RSC_VERSION := "2023.05.0"
RSPM_VERSION := "2023.04.0-6"
RSW_VERSION := "2023.03.0+386.pro1"

DRIVERS_VERSION := "2022.11.0"
DRIVERS_VERSION_RHEL := DRIVERS_VERSION + "-1"

R_VERSION := "3.6.2"
R_VERSION_ALT := "4.1.0"

PYTHON_VERSION := "3.9.5"
PYTHON_VERSION_ALT := "3.8.10"

# just _get-tag-safe-version 2022.07.2+576.pro12
_get-tag-safe-version $VERSION:
  #!/usr/bin/env bash
  echo -n "$VERSION" | sed 's/+/-/g'

# just _get-clean-version 2022.07.2+576.pro12
_get-clean-version $VERSION:
  #!/usr/bin/env bash
  echo -n "$VERSION" | sed 's/[+|-].*//g'

# just _parse-os bionic
_parse-os OS:
  #!/usr/bin/env bash
  if [[ "{{OS}}" == "bionic" ]]; then
    echo "ubuntu1804"
  elif [[ "{{OS}}" == "jammy" ]]; then
    echo "ubuntu2204"
  else
    echo "{{OS}}"
  fi

# just _rev-parse-os ubuntu1804
_rev-parse-os OS:
  #!/usr/bin/env bash
  if [[ "{{OS}}" == "ubuntu1804" ]]; then
    echo "bionic"
  elif [[ "{{OS}}" == "ubuntu2204" ]]; then
    echo "jammy"
  else
    echo "{{OS}}"
  fi

# just
_config-license-persist-volumes TYPE PRODUCT HOST_DIR:
  #!/usr/bin/env bash
  if [ "{{PRODUCT}}" = "package-manager" ]; then
    licensing_state_root_dir="/home/rstudio-pm"
    product_dir_name=".rstudio-pm"
  elif [ "{{PRODUCT}}" = "workbench" ]; then
    licensing_state_root_dir="/var/lib"
    product_dir_name="rstudio-workbench"
  elif [ "{{PRODUCT}}" = "connect" ]; then
    licensing_state_root_dir="/var/lib"
    product_dir_name="rstudio-connect"
  fi

  if [ "{{TYPE}}" = "key" ]; then
    mkdir -p {{HOST_DIR}}/local
    mkdir -p {{HOST_DIR}}/prof
    mkdir -p {{HOST_DIR}}/product

    echo "-v {{HOST_DIR}}/local:${licensing_state_root_dir}/.local -v {{HOST_DIR}}/prof:${licensing_state_root_dir}/.prof -v {{HOST_DIR}}/product:${licensing_state_root_dir}/${product_dir_name}"
  elif [ "{{TYPE}}" = "float" ]; then
    mkdir -p {{HOST_DIR}}/float

    echo "-v {{HOST_DIR}}/float:${licensing_state_root_dir}/.TurboFloat"
  fi

# just RSW_VERSION=1.2.3 R_VERSION=4.1.0 update-versions
update-versions:
  just \
    RSW_VERSION={{RSW_VERSION}} \
    RSC_VERSION={{RSC_VERSION}} \
    RSPM_VERSION={{RSPM_VERSION}} \
    R_VERSION={{R_VERSION}} \
    R_VERSION_ALT={{R_VERSION_ALT}} \
    PYTHON_VERSION={{PYTHON_VERSION}} \
    PYTHON_VERSION_ALT={{PYTHON_VERSION_ALT}} \
    DRIVERS_VERSION={{DRIVERS_VERSION}} \
    update-rsw-versions update-rspm-versions update-rsc-versions update-r-versions update-py-versions update-drivers-versions

# just RSW_VERSION=1.2.3 update-rsw-versions
update-rsw-versions:
  #!/usr/bin/env bash
  set -euxo pipefail
  sed {{ sed_vars }} "s/RSW_VERSION=.*/RSW_VERSION={{ RSW_VERSION }}/g" \
    workbench/.env \
    r-session-complete/.env \
    workbench-for-microsoft-azure-ml/.env \
    r-session-complete/Dockerfile.ubuntu1804 \
    r-session-complete/Dockerfile.ubuntu2204 \
    r-session-complete/Dockerfile.centos7 \
    workbench/Dockerfile.ubuntu1804 \
    workbench/Dockerfile.ubuntu2204 \
    workbench-for-microsoft-azure-ml/Dockerfile.ubuntu1804
  sed {{ sed_vars }} "s/RSW_VERSION:.*/RSW_VERSION: {{ RSW_VERSION }}/g" docker-compose.yml
  sed {{ sed_vars }} "s/rstudio\/rstudio-workbench:.*/rstudio\/rstudio-workbench:$(just _get-clean-version {{ RSW_VERSION }})/g" docker-compose.yml
  sed {{ sed_vars }} "s/org.opencontainers.image.version='.*'/org.opencontainers.image.version='{{ RSW_VERSION }}'/g" workbench-for-microsoft-azure-ml/Dockerfile.ubuntu1804
  sed {{ sed_vars }} "s/^RSW_VERSION := .*/RSW_VERSION := \"{{ RSW_VERSION }}\"/g" \
    r-session-complete/Justfile \
    workbench/Justfile \
    workbench-for-microsoft-azure-ml/Justfile \
    Justfile
  sed {{ sed_vars }} "s/[0-9]\{4\}\.[0-9]\{1,2\}\.[0-9]\{1,2\}/`just _get-clean-version {{ RSW_VERSION }}`/g" \
    workbench/README.md \
    r-session-complete/README.md

# just RSPM_VERSION=1.2.3 update-rspm-versions
update-rspm-versions:
  #!/usr/bin/env bash
  set -euxo pipefail
  sed {{ sed_vars }} "s/RSPM_VERSION=.*/RSPM_VERSION={{ RSPM_VERSION }}/g" \
    package-manager/.env \
    package-manager/Dockerfile.ubuntu1804 \
    package-manager/Dockerfile.ubuntu2204
  sed {{ sed_vars }} "s/RSPM_VERSION:.*/RSPM_VERSION: {{ RSPM_VERSION }}/g" docker-compose.yml
  sed {{ sed_vars }} "s/rstudio\/rstudio-package-manager:.*/rstudio\/rstudio-package-manager:$(just _get-clean-version {{ RSPM_VERSION }})/g" docker-compose.yml
  sed {{ sed_vars }} "s/^RSPM_VERSION := .*/RSPM_VERSION := \"{{ RSPM_VERSION }}\"/g" \
    package-manager/Justfile \
    Justfile
  sed {{ sed_vars }} -E "s/[0-9]{4}\.[0-9]{1,2}\.[0-9]{1,2}/`just _get-clean-version {{ RSPM_VERSION }}`/g" package-manager/README.md

# just RSC_VERSION=1.2.3 update-rsc-versions
update-rsc-versions:
  #!/usr/bin/env bash
  set -euxo pipefail
  sed {{ sed_vars }} "s/RSC_VERSION=.*/RSC_VERSION={{ RSC_VERSION }}/g" \
    connect/.env \
    connect/Dockerfile.ubuntu1804 \
    connect-content-init/Dockerfile.ubuntu1804 \
    connect/Dockerfile.ubuntu2204 \
    connect-content-init/Dockerfile.ubuntu2204
  sed {{ sed_vars }} "s/RSC_VERSION:.*/RSC_VERSION: {{ RSC_VERSION }}/g" docker-compose.yml
  sed {{ sed_vars }} "s/rstudio\/rstudio-connect:.*/rstudio\/rstudio-connect:{{ RSC_VERSION }}/g" docker-compose.yml
  sed {{ sed_vars }} "s/^RSC_VERSION := .*/RSC_VERSION := \"{{ RSC_VERSION }}\"/g" \
    connect/Justfile \
    connect-content-init/Justfile \
    Justfile
  sed {{ sed_vars }} -E "s/[0-9]{4}\.[0-9]{1,2}\.[0-9]{1,2}/`just _get-clean-version {{ RSC_VERSION }}`/g" \
    connect/README.md \
    connect-content-init/README.md

# just R_VERSION=3.2.1 R_VERSION_ALT=4.1.0 update-r-versions
update-r-versions:
  #!/usr/bin/env bash
  set -euxo pipefail
  # Update primary R versions
  sed {{ sed_vars }} "s/^R_VERSION=.*/R_VERSION={{ R_VERSION }}/g" \
    workbench/.env \
    connect/.env \
    package-manager/.env \
    workbench/Dockerfile.ubuntu1804 \
    connect/Dockerfile.ubuntu1804 \
    package-manager/Dockerfile.ubuntu1804 \
    workbench/Dockerfile.ubuntu2204 \
    connect/Dockerfile.ubuntu2204 \
    package-manager/Dockerfile.ubuntu2204
  sed {{ sed_vars }} "s|^RVersion.*=.*|RVersion = /opt/R/{{ R_VERSION }}/|g" package-manager/rstudio-pm.gcfg
  sed {{ sed_vars }} "s/^R_VERSION := .*/R_VERSION := \"{{ R_VERSION }}\"/g" \
    workbench/Justfile \
    workbench-for-microsoft-azure-ml/Justfile \
    connect/Justfile package-manager/Justfile \
    Justfile \
    ci.Justfile

  # Update alt R versions
  sed {{ sed_vars }} "s/^R_VERSION_ALT=.*/R_VERSION_ALT={{ R_VERSION_ALT }}/g" \
    workbench/.env \
    connect/.env \
    workbench/Dockerfile.ubuntu1804 \
    connect/Dockerfile.ubuntu1804 \
    workbench/Dockerfile.ubuntu2204 \
    connect/Dockerfile.ubuntu2204
  sed {{ sed_vars }} "s/^R_VERSION_ALT := .*/R_VERSION_ALT := \"{{ R_VERSION_ALT }}\"/g" \
    workbench/Justfile \
    workbench-for-microsoft-azure-ml/Justfile \
    connect/Justfile \
    Justfile \
    ci.Justfile

# just PYTHON_VERSION=3.9.5 PYTHON_VERSION_ALT=3.8.10 update-py-versions
update-py-versions:
  #!/usr/bin/env bash
  set -euxo pipefail
  # Update primary Python versions
  sed {{ sed_vars }} "s/^PYTHON_VERSION=.*/PYTHON_VERSION={{ PYTHON_VERSION }}/g" \
    workbench/Dockerfile.ubuntu1804 \
    workbench/Dockerfile.ubuntu2204 \
    workbench/.env \
    connect/Dockerfile.ubuntu1804 \
    connect/Dockerfile.ubuntu2204 \
    connect/.env \
    package-manager/Dockerfile.ubuntu1804 \
    package-manager/Dockerfile.ubuntu2204 \
    package-manager/.env
  sed {{ sed_vars }} "s/^PYTHON_VERSION := .*/PYTHON_VERSION := \"{{ PYTHON_VERSION }}\"/g" \
    workbench/Justfile \
    workbench-for-microsoft-azure-ml/Justfile \
    connect/Justfile \
    Justfile \
    ci.Justfile

  # Update alt Python versions
  sed {{ sed_vars }} "s/^PYTHON_VERSION_ALT=.*/PYTHON_VERSION_ALT={{ PYTHON_VERSION_ALT }}/g" \
    workbench/Dockerfile.ubuntu1804 \
    workbench/Dockerfile.ubuntu2204 \
    workbench/.env \
    connect/Dockerfile.ubuntu1804 \
    connect/Dockerfile.ubuntu2204 \
    connect/.env
  sed {{ sed_vars }} "s/^PYTHON_VERSION_ALT := .*/PYTHON_VERSION_ALT := \"{{ PYTHON_VERSION_ALT }}\"/g" \
    workbench/Justfile \
    workbench-for-microsoft-azure-ml/Justfile \
    connect/Justfile \
    Justfile \
    ci.Justfile

# just DRIVERS_VERSION=2022.11.0 update-driver-versions
update-drivers-versions:
  #!/usr/bin/env bash
  set -euxo pipefail
  sed {{ sed_vars }} "s/\"drivers\": \".[^\,\}]*\"/\"drivers\": \"{{ DRIVERS_VERSION }}\"/g" content/matrix.json
  sed {{ sed_vars }} "s/DRIVERS_VERSION=.*/DRIVERS_VERSION={{ DRIVERS_VERSION }}/g" \
    workbench-for-microsoft-azure-ml/Dockerfile.ubuntu1804 \
    r-session-complete/Dockerfile.ubuntu* \
    product/pro/Dockerfile.ubuntu*
  sed {{ sed_vars }} "s/DRIVERS_VERSION=.*/DRIVERS_VERSION={{ DRIVERS_VERSION_RHEL }}/g" \
    r-session-complete/.env \
    r-session-complete/Dockerfile.centos7 \
    product/pro/Dockerfile.centos7
  sed {{ sed_vars }} "s/^DRIVERS_VERSION := .*/DRIVERS_VERSION := \"{{ DRIVERS_VERSION }}\"/g" \
    content/pro/Justfile \
    r-session-complete/Justfile \
    product/pro/Justfile \
    Justfile

# just test-image preview workbench 12.0.11-8 tag1 tag2 tag3 ...
test-image $PRODUCT $VERSION +IMAGES:
  #!/usr/bin/env bash
  set -euxo pipefail
  IMAGES="{{IMAGES}}"
  read -ra IMAGE_ARRAY <<<"$IMAGES"
  just \
    R_VERSION={{R_VERSION}} \
    R_VERSION_ALT={{R_VERSION_ALT}} \
    PYTHON_VERSION={{PYTHON_VERSION}} \
    PYTHON_VERSION_ALT={{PYTHON_VERSION_ALT}} \
    $PRODUCT/test "${IMAGE_ARRAY[0]}" "$VERSION"

# just lint workbench ubuntu1804
lint $PRODUCT $OS:
  #!/usr/bin/env bash
  docker run --rm -i -v $PWD/hadolint.yaml:/.config/hadolint.yaml ghcr.io/hadolint/hadolint < $PRODUCT/Dockerfile.$(just _parse-os {{OS}})
