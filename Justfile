set positional-arguments

vars := "-i ''"

sed_vars := if os() == "macos" { "-i ''" } else { "-i" }

BUILDX_PATH := ""

RSC_VERSION := "2022.10.0"
RSPM_VERSION := "2022.07.2-11"
RSW_VERSION := "2022.07.2+576.pro12"
RSC_TAG_SAFE_VERSION := replace(RSW_VERSION, "+", "-")

DRIVERS_VERSION := "2021.10.0"
DRIVERS_VERSION_RHEL := "2021.10.0-1"

R_VERSION := "3.6.2"
R_VERSION_ALT := "4.1.0"

PYTHON_VERSION := "3.9.5"
PYTHON_VERSION_ALT := "3.8.10"

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
    r-session-complete/Dockerfile.bionic \
    r-session-complete/Dockerfile.centos7 \
    workbench/Dockerfile.bionic \
    workbench-for-microsoft-azure-ml/Dockerfile.bionic
  sed {{ sed_vars }} "s/RSW_VERSION:.*/RSW_VERSION: {{ RSW_VERSION }}/g" docker-compose.yml
  sed {{ sed_vars }} "s/rstudio\/rstudio-workbench:.*/rstudio\/rstudio-workbench:{{ RSC_TAG_SAFE_VERSION }}/g" docker-compose.yml
  sed {{ sed_vars }} "s/org.opencontainers.image.version='.*'/org.opencontainers.image.version='{{ RSW_VERSION }}'/g" workbench-for-microsoft-azure-ml/Dockerfile.bionic
  sed {{ sed_vars }} "s/^RSW_VERSION := .*/RSW_VERSION := \"{{ RSW_VERSION }}\"/g" \
    r-session-complete/Justfile \
    workbench/Justfile \
    workbench-for-microsoft-azure-ml/Justfile \
    Justfile

# just RSPM_VERSION=1.2.3 update-rspm-versions
update-rspm-versions:
  #!/usr/bin/env bash
  set -euxo pipefail
  sed {{ sed_vars }} "s/RSPM_VERSION=.*/RSPM_VERSION={{ RSPM_VERSION }}/g" \
    package-manager/.env \
    package-manager/Dockerfile.bionic
  sed {{ sed_vars }} "s/RSPM_VERSION:.*/RSPM_VERSION: {{ RSPM_VERSION }}/g" docker-compose.yml
  sed {{ sed_vars }} "s/rstudio\/rstudio-package-manager:.*/rstudio\/rstudio-package-manager:{{ RSPM_VERSION }}/g" docker-compose.yml
  sed {{ sed_vars }} "s/^RSPM_VERSION := .*/RSPM_VERSION := \"{{ RSPM_VERSION }}\"/g" \
    package-manager/Justfile \
    Justfile

# just RSC_VERSION=1.2.3 update-rsc-versions
update-rsc-versions:
  #!/usr/bin/env bash
  set -euxo pipefail
  sed {{ sed_vars }} "s/RSC_VERSION=.*/RSC_VERSION={{ RSC_VERSION }}/g" \
    connect/.env \
    connect/Dockerfile.bionic \
    connect-content-init/Dockerfile.bionic
  sed {{ sed_vars }} "s/RSC_VERSION:.*/RSC_VERSION: {{ RSC_VERSION }}/g" docker-compose.yml
  sed {{ sed_vars }} "s/rstudio\/rstudio-connect:.*/rstudio\/rstudio-connect:{{ RSC_VERSION }}/g" docker-compose.yml
  sed {{ sed_vars }} "s/^RSC_VERSION := .*/RSC_VERSION := \"{{ RSC_VERSION }}\"/g" \
    connect/Justfile \
    Justfile

# just R_VERSION=3.2.1 R_VERSION_ALT=4.1.0 update-r-versions
update-r-versions:
  #!/usr/bin/env bash
  set -euxo pipefail
  # Update primary R versions
  sed {{ sed_vars }} "s/R_VERSION=.*/R_VERSION={{ R_VERSION }}/g" \
    workbench/.env \
    connect/.env \
    package-manager/.env \
    workbench/Dockerfile.bionic \
    connect/Dockerfile.bionic \
    package-manager/Dockerfile.bionic
  sed {{ sed_vars }} "s|^RVersion.*=.*|RVersion = /opt/R/{{ R_VERSION }}/|g" package-manager/rstudio-pm.gcfg
  sed {{ sed_vars }} "s/^R_VERSION := .*/R_VERSION := \"{{ R_VERSION }}\"/g" \
    workbench/Justfile \
    workbench-for-microsoft-azure-ml/Justfile \
    connect/Justfile package-manager/Justfile \
    Justfile

  # Update alt R versions
  sed {{ sed_vars }} "s/R_VERSION_ALT=.*/R_VERSION_ALT={{ R_VERSION_ALT }}/g" \
    workbench/.env \
    connect/.env \
    workbench/Dockerfile.bionic \
    connect/Dockerfile.bionic
  sed {{ sed_vars }} "s/^R_VERSION_ALT := .*/R_VERSION_ALT := \"{{ R_VERSION_ALT }}\"/g" \
    workbench/Justfile \
    workbench-for-microsoft-azure-ml/Justfile \
    connect/Justfile \
    Justfile

# just PYTHON_VERSION=3.9.5 PYTHON_VERSION_ALT=3.8.10 update-py-versions
update-py-versions:
  #!/usr/bin/env bash
  set -euxo pipefail
  # Update primary Python versions
  sed {{ sed_vars }} "s/PYTHON_VERSION=.*/PYTHON_VERSION={{ PYTHON_VERSION }}/g" \
    workbench/Dockerfile.bionic \
    workbench/.env \
    connect/Dockerfile.bionic \
    connect/.env \
    package-manager/Dockerfile.bionic \
    package-manager/.env
  sed {{ sed_vars }} "s/^PYTHON_VERSION := .*/PYTHON_VERSION := \"{{ PYTHON_VERSION }}\"/g" \
    workbench/Justfile \
    workbench-for-microsoft-azure-ml/Justfile \
    connect/Justfile \
    Justfile

  # Update alt Python versions
  sed {{ sed_vars }} "s/PYTHON_VERSION_ALT=.*/PYTHON_VERSION_ALT={{ PYTHON_VERSION_ALT }}/g" \
    workbench/Dockerfile.bionic \
    workbench/.env \
    connect/Dockerfile.bionic \
    connect/.env \
    workbench/Justfile \
    workbench-for-microsoft-azure-ml/Justfile \
    connect/Justfile \
    Justfile

# just DRIVERS_VERSION=2021.10.0 update-driver-versions
update-drivers-versions:
  #!/usr/bin/env bash
  set -euxo pipefail
  sed {{ sed_vars }} "s/\"drivers\": \".[^\,\}]*\"/\"drivers\": \"{{ DRIVERS_VERSION }}\"/g" content/matrix.json
  sed {{ sed_vars }} "s/DRIVERS_VERSION=.*/DRIVERS_VERSION={{ DRIVERS_VERSION }}/g" workbench-for-microsoft-azure-ml/Dockerfile.bionic
  sed {{ sed_vars }} "s/DRIVERS_VERSION=.*/DRIVERS_VERSION={{ DRIVERS_VERSION_RHEL }}/g" r-session-complete/Dockerfile.centos7
  sed {{ sed_vars }} "s/^DRIVERS_VERSION := .*/DRIVERS_VERSION := \"{{ DRIVERS_VERSION }}\"/g" \
    content/pro/Justfile \
    Justfile

# just test-image preview workbench 12.0.11-8 tag1 tag2 tag3 ...
test-image $PRODUCT $VERSION +IMAGES:
  #!/usr/bin/env bash
  set -euxo pipefail
  IMAGES="{{IMAGES}}"
  read -ra IMAGE_ARRAY <<<"$IMAGES"
  just $PRODUCT/test "${IMAGE_ARRAY[0]}" "$VERSION"

# just lint workbench bionic
lint $PRODUCT $OS:
  #!/usr/bin/env bash
  docker run --rm -i -v $PWD/hadolint.yaml:/.config/hadolint.yaml ghcr.io/hadolint/hadolint < $PRODUCT/Dockerfile.$OS
