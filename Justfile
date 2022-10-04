set positional-arguments

vars := "-i ''"

sed_vars := if os() == "macos" { "-i ''" } else { "-i" }

BUILDX_PATH := ""

RSC_VERSION := "2022.09.0"
RSPM_VERSION := "2022.07.2-11"
RSW_VERSION := "2022.07.2+576.pro12"
RSW_TAG_VERSION := replace(RSW_VERSION, "+", "-")

DRIVERS_VERSION := "2021.10.0"

R_VERSION := "3.6.2"
R_VERSION_ALT := "4.1.0"

PYTHON_VERSION := "3.9.5"
PYTHON_VERSION_ALT := "3.8.10"

# just RSW_VERSION=1.2.3 update-versions
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
  sed {{ sed_vars }} "s/^RSW_VERSION=.*/RSW_VERSION={{ RSW_VERSION }}/g" workbench/.env
  sed {{ sed_vars }} "s/^RSW_VERSION=.*/RSW_VERSION={{ RSW_VERSION }}/g" r-session-complete/.env
  sed {{ sed_vars }} "s/^RSW_VERSION=.*/RSW_VERSION={{ RSW_VERSION }}/g" workbench-for-microsoft-azure-ml/.env
  sed {{ sed_vars }} "s/^ARG RSW_VERSION=.*/ARG RSW_VERSION={{ RSW_VERSION }}/g" r-session-complete/Dockerfile.bionic
  sed {{ sed_vars }} "s/^ARG RSW_VERSION=.*/ARG RSW_VERSION={{ RSW_VERSION }}/g" r-session-complete/Dockerfile.centos7
  sed {{ sed_vars }} "s/^ARG RSW_VERSION=.*/ARG RSW_VERSION={{ RSW_VERSION }}/g" workbench/Dockerfile.bionic
  sed {{ sed_vars }} "s/RSW_VERSION:.*/RSW_VERSION: {{ RSW_VERSION }}/g" docker-compose.yml
  sed {{ sed_vars }} "s/rstudio\/rstudio-workbench:.*/rstudio\/rstudio-workbench:{{ RSW_TAG_VERSION }}/g" docker-compose.yml
  sed {{ sed_vars }} "s/^ARG RSW_VERSION=.*/ARG RSW_VERSION={{ RSW_VERSION }}/g" workbench-for-microsoft-azure-ml/Dockerfile.bionic
  sed {{ sed_vars }} "s/org.opencontainers.image.version='.*'/org.opencontainers.image.version='{{ RSW_VERSION }}'/g" workbench-for-microsoft-azure-ml/Dockerfile.bionic
  sed {{ sed_vars }} "s/^RSW_VERSION ?= .*/RSW_VERSION ?= {{ RSW_VERSION }}/g" Makefile
  sed {{ sed_vars }} "s/^RSW_VERSION := .*/RSW_VERSION := \"{{ RSW_VERSION }}\"/g" Justfile

# just RSPM_VERSION=1.2.3 update-rspm-versions
update-rspm-versions:
  #!/usr/bin/env bash
  set -euxo pipefail
  sed {{ sed_vars }} "s/^RSPM_VERSION=.*/RSPM_VERSION={{ RSPM_VERSION }}/g" package-manager/.env
  sed {{ sed_vars }} "s/^ARG RSPM_VERSION=.*/ARG RSPM_VERSION={{ RSPM_VERSION }}/g" package-manager/Dockerfile.bionic
  sed {{ sed_vars }} "s/^RSPM_VERSION:.*/RSPM_VERSION: {{ RSPM_VERSION }}/g" docker-compose.yml
  sed {{ sed_vars }} "s/RSPM_VERSION:.*/RSPM_VERSION: {{ RSPM_VERSION }}/g" docker-compose.yml
  sed {{ sed_vars }} "s/rstudio\/rstudio-package-manager:.*/rstudio\/rstudio-package-manager:{{ RSPM_VERSION }}/g" docker-compose.yml
  sed {{ sed_vars }} "s/^RSPM_VERSION ?= .*/RSPM_VERSION ?= {{ RSPM_VERSION }}/g" Makefile
  sed {{ sed_vars }} "s/^RSPM_VERSION := .*/RSPM_VERSION := \"{{ RSPM_VERSION }}\"/g" Justfile

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
  sed {{ sed_vars }} "s/^RSC_VERSION ?= .*/RSC_VERSION ?= {{ RSC_VERSION }}/g" Makefile
  sed {{ sed_vars }} "s/^RSC_VERSION := .*/RSC_VERSION := \"{{ RSC_VERSION }}\"/g" Justfile

# just R_VERSION=3.2.1 R_VERSION_ALT=4.1.0 update-r-versions
update-r-versions:
  #!/usr/bin/env bash
  set -euxo pipefail
  # Update primary R versions
  sed {{ sed_vars }} "s/^R_VERSION:.*/R_VERSION={{ R_VERSION }}/g" workbench/Dockerfile.bionic
  sed {{ sed_vars }} "s/^R_VERSION=.*/R_VERSION={{ R_VERSION }}/g" workbench/.env
  sed {{ sed_vars }} "s/^R_VERSION:.*/R_VERSION={{ R_VERSION }}/g" connect/Dockerfile.bionic
  sed {{ sed_vars }} "s/^R_VERSION=.*/R_VERSION={{ R_VERSION }}/g" connect/.env
  sed {{ sed_vars }} "s/^R_VERSION:.*/R_VERSION={{ R_VERSION }}/g" package-manager/Dockerfile.bionic
  sed {{ sed_vars }} "s/^R_VERSION=.*/R_VERSION={{ R_VERSION }}/g" package-manager/.env
  sed {{ sed_vars }} "s|^RVersion.*=.*|RVersion = /opt/R/{{ R_VERSION }}/|g" package-manager/rstudio-pm.gcfg
  sed {{ sed_vars }} "s/^R_VERSION ?= .*/R_VERSION ?= {{ R_VERSION }}/g" Makefile
  sed {{ sed_vars }} "s/^R_VERSION := .*/R_VERSION := \"{{ R_VERSION }}\"/g" Justfile

  # Update alt R versions
  sed {{ sed_vars }} "s/^R_VERSION_ALT:.*/R_VERSION_ALT={{ R_VERSION_ALT }}/g" workbench/Dockerfile.bionic
  sed {{ sed_vars }} "s/^R_VERSION_ALT=.*/R_VERSION_ALT={{ R_VERSION_ALT }}/g" workbench/.env
  sed {{ sed_vars }} "s/^R_VERSION_ALT:.*/R_VERSION_ALT={{ R_VERSION_ALT }}/g" connect/Dockerfile.bionic
  sed {{ sed_vars }} "s/^R_VERSION_ALT=.*/R_VERSION_ALT={{ R_VERSION_ALT }}/g" connect/.env
  sed {{ sed_vars }} "s/^R_VERSION_ALT ?= .*/R_VERSION_ALT ?= {{ R_VERSION_ALT }}/g" Makefile
  sed {{ sed_vars }} "s/^R_VERSION_ALT := .*/R_VERSION_ALT := \"{{ R_VERSION_ALT }}\"/g" Justfile

# just PYTHON_VERSION=3.9.5 PYTHON_VERSION_ALT=3.8.10 update-py-versions
update-py-versions:
  #!/usr/bin/env bash
  set -euxo pipefail
  # Update primary Python versions
  sed {{ sed_vars }} "s/^PYTHON_VERSION:.*/PYTHON_VERSION={{ PYTHON_VERSION }}/g" workbench/Dockerfile.bionic
  sed {{ sed_vars }} "s/^PYTHON_VERSION=.*/PYTHON_VERSION={{ PYTHON_VERSION }}/g" workbench/.env
  sed {{ sed_vars }} "s/^PYTHON_VERSION:.*/PYTHON_VERSION={{ PYTHON_VERSION }}/g" connect/Dockerfile.bionic
  sed {{ sed_vars }} "s/^PYTHON_VERSION=.*/PYTHON_VERSION={{ PYTHON_VERSION }}/g" connect/.env
  sed {{ sed_vars }} "s/^PYTHON_VERSION:.*/PYTHON_VERSION={{ PYTHON_VERSION }}/g" package-manager/Dockerfile.bionic
  sed {{ sed_vars }} "s/^PYTHON_VERSION=.*/PYTHON_VERSION={{ PYTHON_VERSION }}/g" package-manager/.env
  sed {{ sed_vars }} "s/^PYTHON_VERSION ?= .*/PYTHON_VERSION ?= {{ PYTHON_VERSION }}/g" Makefile
  sed {{ sed_vars }} "s/^PYTHON_VERSION := .*/PYTHON_VERSION := \"{{ PYTHON_VERSION }}\"/g" Justfile

  # Update alt Python versions
  sed {{ sed_vars }} "s/^PYTHON_VERSION_ALT:.*/PYTHON_VERSION_ALT={{ PYTHON_VERSION_ALT }}/g" workbench/Dockerfile.bionic
  sed {{ sed_vars }} "s/^PYTHON_VERSION_ALT=.*/PYTHON_VERSION_ALT={{ PYTHON_VERSION_ALT }}/g" workbench/.env
  sed {{ sed_vars }} "s/^PYTHON_VERSION_ALT:.*/PYTHON_VERSION_ALT={{ PYTHON_VERSION_ALT }}/g" connect/Dockerfile.bionic
  sed {{ sed_vars }} "s/^PYTHON_VERSION_ALT=.*/PYTHON_VERSION_ALT={{ PYTHON_VERSION_ALT }}/g" connect/.env
  sed {{ sed_vars }} "s/^PYTHON_VERSION_ALT ?= .*/PYTHON_VERSION_ALT ?= {{ PYTHON_VERSION_ALT }}/g" Makefile
  sed {{ sed_vars }} "s/^PYTHON_VERSION_ALT := .*/PYTHON_VERSION_ALT := \"{{ PYTHON_VERSION_ALT }}\"/g" Justfile

# just DRIVERS_VERSION=2021.10.0 update-driver-versions
update-drivers-versions:
  #!/usr/bin/env bash
  set -euxo pipefail
  sed {{ sed_vars }} "s/^DRIVERS_VERSION=.*/DRIVERS_VERSION={{ DRIVERS_VERSION }}/g" content/pro/Makefile
  sed {{ sed_vars }} "s/\"drivers\": \".[^\,\}]*\"/\"drivers\": \"{{ DRIVERS_VERSION }}\"/g" content/matrix.json
  sed {{ sed_vars }} "s/^ARG DRIVERS_VERSION=.*/ARG DRIVERS_VERSION={{ DRIVERS_VERSION }}/g" helper/workbench-for-microsoft-azure-ml/Dockerfile
  sed {{ sed_vars }} "s/^DRIVERS_VERSION ?= .*/DRIVERS_VERSION ?= {{ DRIVERS_VERSION }}/g" Makefile
  sed {{ sed_vars }} "s/^DRIVERS_VERSION := .*/DRIVERS_VERSION := \"{{ DRIVERS_VERSION }}\"/g" Justfile

build-release $PRODUCT $OS:
  #!/usr/bin/env bash
  make PRODUCT=${PRODUCT} IMAGE_OS=${OS} build

# just BUILDX_PATH=~/.buildx build-preview preview workbench bionic
build-preview $TYPE $PRODUCT $OS:
  #!/usr/bin/env bash
  make PRODUCT=${PRODUCT} IMAGE_OS=${OS} PREVIEW_TYPE=${TYPE}  build-preview

# just push-images tag1 tag2 ...
push-images +IMAGES:
  #!/usr/bin/env bash
  set -euxo pipefail
  for IMAGE in {{IMAGES}}
  do
    docker push $IMAGE
  done

# just test workbench bionic
test $PRODUCT $OS:
  #!/usr/bin/env bash
  make PRODUCT=${PRODUCT} IMAGE_OS=${OS} test

# just test-image workbench 12.0.11-8 tag1 tag2 tag3 ...
test-image $PRODUCT $VERSION +IMAGES:
  #!/usr/bin/env bash
  set -euxo pipefail
  IMAGES="{{IMAGES}}"
  read -ra IMAGE_ARRAY <<<"$IMAGES"
  make PRODUCT={{PRODUCT}} TEST_IMAGE_NAME="${IMAGE_ARRAY[0]}" VERSION={{VERSION}} test

# just get-version workbench --type=preview --local
get-version +NARGS:
  ./get-version.py {{NARGS}}

lint $PRODUCT $OS:
  #!/usr/bin/env bash
  docker run --rm -i -v $PWD/hadolint.yaml:/.config/hadolint.yaml ghcr.io/hadolint/hadolint < $PRODUCT/Dockerfile.$OS
