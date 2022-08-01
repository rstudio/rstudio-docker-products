set positional-arguments

vars := "-i ''"

sed_vars := if os() == "macos" { "-i ''" } else { "-i" }

RSW_VERSION := "2022.07.1+554.pro3"
RSW_TAG_VERSION := replace(RSW_VERSION, "+", "-")
RSC_VERSION := "2022.07.0"
RSPM_VERSION := "2022.07.0-9"
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
  sed {{ sed_vars }} "s/^ARG RSW_VERSION=.*/ARG RSW_VERSION={{ RSW_VERSION }}/g" workbench/Dockerfile
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

# just R_VERSION=3.2.1 update-r-versions
update-r-versions:
  #!/usr/bin/env bash
  set -euxo pipefail
  sed {{ sed_vars }} "s/^R_VERSION:.*/R_VERSION={{ R_VERSION }}/g" workbench/Dockerfile.bionic
  sed {{ sed_vars }} "s/^R_VERSION:.*/R_VERSION={{ R_VERSION }}/g" connect/Dockerfile.bionic
  sed {{ sed_vars }} "s/^R_VERSION:.*/R_VERSION={{ R_VERSION }}/g" package-manager/Dockerfile.bionic
  sed {{ sed_vars }} "s|^RVersion.*=.*|RVersion = /opt/R/{{ R_VERSION }}/|g" package-manager/rstudio-pm.gcfg
