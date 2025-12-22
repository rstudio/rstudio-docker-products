#!/usr/bin/env just --justfile
set positional-arguments

vars := "-i ''"

sed_vars := if os() == "macos" { "-i ''" } else { "-i" }

BUILDX_PATH := ""
REGISTRY_NAMESPACE := "rstudio"

RSC_VERSION := "2025.12.1"
RSPM_VERSION := "2025.12.0-12"
RSW_VERSION := "2025.09.2+418.pro4"

DRIVERS_VERSION := "2025.07.0"
DRIVERS_VERSION_RHEL := DRIVERS_VERSION + "-1"

SNYK_ORG := env("SNYK_ORG", "")

export RSC_LICENSE := ""
export RSPM_LICENSE := ""
export RSW_LICENSE := ""

# Targets for managing the buildx builder for Posit images

# just create-builder
create-builder:
  docker buildx create \
    --name posit-builder \
    --buildkitd-flags '--allow-insecure-entitlement security.insecure' \
    --buildkitd-config "{{justfile_directory()}}/share/local_buildkitd.toml"

# just delete-builder
delete-builder:
  docker buildx rm posit-builder

# Build and bake

# just build
alias build := bake
# just bake workbench-images
bake target="default":
  just create-builder || true
  GIT_SHA=$(git rev-parse --short HEAD) \
    docker buildx bake --builder=posit-builder -f docker-bake.hcl {{target}}

# just preview-bake workbench-images dev
alias preview-build := preview-bake
preview-bake target branch="$(git branch --show-current)":
  just create-builder || true
  WORKBENCH_DAILY_VERSION=$(just get-version workbench --type=daily --local) \
  WORKBENCH_PREVIEW_VERSION=$(just get-version workbench --type=preview --local) \
  PACKAGE_MANAGER_DAILY_VERSION=$(just get-version package-manager --type=daily --local) \
  PACKAGE_MANAGER_PREVIEW_VERSION=$(just get-version package-manager --type=preview --local) \
  CONNECT_DAILY_VERSION=$(just get-version connect --type=daily --local) \
  BRANCH="{{branch}}" \
    docker buildx bake --builder=posit-builder -f docker-bake.preview.hcl {{target}}

content-bake:
  just create-builder || true
  cd {{justfile_directory()}}/content && docker buildx bake --builder=posit-builder
  cd {{justfile_directory()}}

# just plan
plan:
  GIT_SHA=$(git rev-parse --short HEAD) \
    docker buildx bake -f docker-bake.hcl --print

# just preview-plan
preview-plan branch="$(git branch --show-current)":
  WORKBENCH_DAILY_VERSION=$(just get-version workbench --type=daily --local) \
  WORKBENCH_PREVIEW_VERSION=$(just get-version workbench --type=preview --local) \
  PACKAGE_MANAGER_DAILY_VERSION=$(just get-version package-manager --type=daily --local) \
  CONNECT_DAILY_VERSION=$(just get-version connect --type=daily --local) \
  BRANCH="{{branch}}" \
    docker buildx bake -f docker-bake.preview.hcl --print

# Run tests

# just test workbench
test target="default" file="docker-bake.hcl":
  GIT_SHA=$(git rev-parse --short HEAD) \
    python3 {{justfile_directory()}}/tools/test_bake_artifacts.py --target "{{target}}" --file "{{file}}"

# just preview-test connect dev
preview-test target="default" branch="$(git branch --show-current)":
  #!/bin/bash
  if [ -z "$WORKBENCH_DAILY_VERSION" ]; then
    WORKBENCH_DAILY_VERSION=$(just get-version workbench --type=daily --local)
  fi
  if [ -z "$WORKBENCH_PREVIEW_VERSION" ]; then
    WORKBENCH_PREVIEW_VERSION=$(just get-version workbench --type=preview --local)
  fi
  if [ -z "$PACKAGE_MANAGER_DAILY_VERSION" ]; then
    PACKAGE_MANAGER_DAILY_VERSION=$(just get-version package-manager --type=daily --local)
  fi
  if [ -z "$CONNECT_DAILY_VERSION" ]; then
    CONNECT_DAILY_VERSION=$(just get-version connect --type=daily --local)
  fi
  if [ -z "$BRANCH" ]; then
    BRANCH="{{branch}}"
  fi
  WORKBENCH_DAILY_VERSION="${WORKBENCH_DAILY_VERSION}" \
  WORKBENCH_PREVIEW_VERSION="${WORKBENCH_PREVIEW_VERSION}" \
  PACKAGE_MANAGER_DAILY_VERSION="${PACKAGE_MANAGER_DAILY_VERSION}" \
  CONNECT_DAILY_VERSION="${CONNECT_DAILY_VERSION}" \
  BRANCH="${BRANCH}" \
  python3 {{justfile_directory()}}/tools/test_bake_artifacts.py --file docker-bake.preview.hcl --target "{{target}}"

# just snyk-code-test
snyk-code-test:
  snyk code test --org="{{SNYK_ORG}}" --sarif-file-output=code.sarif {{justfile_directory()}}

# just snyk-test workbench
snyk-test target="default" file="docker-bake.hcl" *opts="":
  SNYK_ORG="{{SNYK_ORG}}" \
  GIT_SHA=$(git rev-parse --short HEAD) \
    python3 {{justfile_directory()}}/tools/snyk_bake_artifacts.py --target "{{target}}" --file "{{file}}" test {{opts}}

# just snyk-monitor workbench
snyk-monitor target="default" file="docker-bake.hcl" *opts="":
  SNYK_ORG="{{SNYK_ORG}}" \
  GIT_SHA=$(git rev-parse --short HEAD) \
    python3 {{justfile_directory()}}/tools/snyk_bake_artifacts.py --target "{{target}}" --file "{{file}}" monitor {{opts}}

# just snyk-sbom workbench
snyk-sbom target="default" file="docker-bake.hcl" *opts="":
  SNYK_ORG="{{SNYK_ORG}}" \
  GIT_SHA=$(git rev-parse --short HEAD) \
    python3 {{justfile_directory()}}/tools/snyk_bake_artifacts.py --target "{{target}}" --file "{{file}}" sbom {{opts}}

# just snyk-ignore workbench SNYK-XXXX-XXXX-XXXX "Reported upstream in <link>" 2024-08-31
snyk-ignore context snyk_id reason expiry:
  snyk ignore --id="{{snyk_id}}" --reason="{{reason}}" --expiry="{{expiry}}" --policy-path="{{context}}"

# just preview-snyk-test workbench
preview-snyk-test target="default" branch="$(git branch --show-current)" *opts="":
  WORKBENCH_DAILY_VERSION=$(just get-version workbench --type=daily --local) \
  WORKBENCH_PREVIEW_VERSION=$(just get-version workbench --type=preview --local) \
  PACKAGE_MANAGER_DAILY_VERSION=$(just get-version package-manager --type=daily --local) \
  CONNECT_DAILY_VERSION=$(just get-version connect --type=daily --local) \
  BRANCH="{{branch}}" \
  SNYK_ORG="{{SNYK_ORG}}" \
  GIT_SHA=$(git rev-parse --short HEAD) \
    python3 {{justfile_directory()}}/tools/snyk_bake_artifacts.py --target "{{target}}" --file "docker-bake.preview.hcl" test {{opts}}

# just snyk-monitor workbench
preview-snyk-monitor target="default" branch="$(git branch --show-current)" *opts="":
  WORKBENCH_DAILY_VERSION=$(just get-version workbench --type=daily --local) \
  WORKBENCH_PREVIEW_VERSION=$(just get-version workbench --type=preview --local) \
  PACKAGE_MANAGER_DAILY_VERSION=$(just get-version package-manager --type=daily --local) \
  CONNECT_DAILY_VERSION=$(just get-version connect --type=daily --local) \
  BRANCH="{{branch}}" \
  SNYK_ORG="{{SNYK_ORG}}" \
  GIT_SHA=$(git rev-parse --short HEAD) \
    python3 {{justfile_directory()}}/tools/snyk_bake_artifacts.py --target "{{target}}" --file "docker-bake.preview.hcl" monitor {{opts}}

# just snyk-sbom workbench
preview-snyk-sbom target="default" branch="$(git branch --show-current)" *opts="":
  WORKBENCH_DAILY_VERSION=$(just get-version workbench --type=daily --local) \
  WORKBENCH_PREVIEW_VERSION=$(just get-version workbench --type=preview --local) \
  PACKAGE_MANAGER_DAILY_VERSION=$(just get-version package-manager --type=daily --local) \
  CONNECT_DAILY_VERSION=$(just get-version connect --type=daily --local) \
  BRANCH="{{branch}}" \
  SNYK_ORG="{{SNYK_ORG}}" \
  GIT_SHA=$(git rev-parse --short HEAD) \
    python3 {{justfile_directory()}}/tools/snyk_bake_artifacts.py --target "{{target}}" --file "docker-bake.preview.hcl" sbom {{opts}}

# just lint workbench ubuntu2204
lint $PRODUCT $OS:
  #!/usr/bin/env bash
  docker run --rm -i -v $PWD/hadolint.yaml:/.config/hadolint.yaml ghcr.io/hadolint/hadolint < $PRODUCT/Dockerfile.$(just _parse-os {{OS}})

# Run targets

run product tag="":
  #!/bin/bash
  RSC_VERSION="ubuntu2204"
  RSW_VERSION="ubuntu2204"
  RSPM_VERSION="ubuntu2204"
  if [ "{{product}}" = "workbench" ] && [ -z "{{tag}}" ]; then
    RSW_VERSION="{{tag}}"
  elif [ "{{product}}" = "connect" ] && [ -z "{{tag}}" ]; then
    RSC_VERSION="{{tag}}"
  elif [ "{{product}}" = "package-manager" ] && [ -z "{{tag}}" ]; then
    RSPM_VERSION="{{tag}}"
  fi
  RSW_VERSION="${RSW_VERSION}" RSC_VERSION="${RSC_VERSION}" RSPM_VERSION="${RSPM_VERSION}" \
    docker compose up \
    --no-build \
    {{product}}

# Export/import targets

export-artifacts target build_definition="docker-bake.hcl":
  python3 {{justfile_directory()}}/tools/export_bake_artifacts.py --target "{{target}}" --file "{{build_definition}}"

import-artifacts:
  python3 {{justfile_directory()}}/tools/import_bake_artifacts.py

# Helper targets

# just get-version workbench --type=preview --local
get-version +NARGS:
  ./tools/get-version.py {{NARGS}}

# just _get-clean-version 2022.07.2+576.pro12
_get-clean-version $VERSION:
  #!/usr/bin/env bash
  echo -n "$VERSION" | sed 's/[+|-].*//g'

# just _parse-os jammy
_parse-os OS:
  #!/usr/bin/env bash
  if [[ "{{OS}}" == "jammy" ]]; then
    echo "ubuntu2204"
  else
    echo "{{OS}}"
  fi

# Version and dependency version management

# just RSW_VERSION=1.2.3 R_VERSION=4.1.0 update-versions
update-versions:
  just \
    RSW_VERSION={{RSW_VERSION}} \
    RSC_VERSION={{RSC_VERSION}} \
    RSPM_VERSION={{RSPM_VERSION}} \
    DRIVERS_VERSION={{DRIVERS_VERSION}} \
    update-rsw-versions update-rspm-versions update-rsc-versions update-drivers-versions

# just RSW_VERSION=1.2.3 update-rsw-versions
update-rsw-versions:
  #!/usr/bin/env bash
  set -euxo pipefail
  sed {{ sed_vars }} "s/^RSW_VERSION := .*/RSW_VERSION := \"{{ RSW_VERSION }}\"/g" \
    Justfile
  sed {{ sed_vars }} "s/[0-9]\{4\}\.[0-9]\{1,2\}\.[0-9]\{1,2\}/`just _get-clean-version {{ RSW_VERSION }}`/g" \
    workbench/README.md \
    r-session-complete/README.md \
    workbench-session-init/README.md
  awk -v new_version="{{ RSW_VERSION }}" '
  /variable WORKBENCH_VERSION/ { print; getline; print "    default = \"" new_version "\""; next }
  { print }
  ' docker-bake.hcl > file.tmp && mv file.tmp docker-bake.hcl

# just RSPM_VERSION=1.2.3 update-rspm-versions
update-rspm-versions:
  #!/usr/bin/env bash
  set -euxo pipefail
  sed {{ sed_vars }} "s/^RSPM_VERSION := .*/RSPM_VERSION := \"{{ RSPM_VERSION }}\"/g" \
    Justfile
  sed {{ sed_vars }} -E "s/[0-9]{4}\.[0-9]{1,2}\.[0-9]{1,2}/`just _get-clean-version {{ RSPM_VERSION }}`/g" package-manager/README.md
  awk -v new_version="{{ RSPM_VERSION }}" '
  /variable PACKAGE_MANAGER_VERSION/ { print; getline; print "    default = \"" new_version "\""; next }
  { print }
  ' docker-bake.hcl > file.tmp && mv file.tmp docker-bake.hcl

# just RSC_VERSION=1.2.3 update-rsc-versions
update-rsc-versions:
  #!/usr/bin/env bash
  set -euxo pipefail
  sed {{ sed_vars }} "s/^RSC_VERSION := .*/RSC_VERSION := \"{{ RSC_VERSION }}\"/g" \
    Justfile
  sed {{ sed_vars }} -E "s/[0-9]{4}\.[0-9]{1,2}\.[0-9]{1,2}/`just _get-clean-version {{ RSC_VERSION }}`/g" \
    connect/README.md \
    connect-content-init/README.md
  awk -v new_version="{{ RSC_VERSION }}" '
  /variable CONNECT_VERSION/ { print; getline; print "    default = \"" new_version "\""; next }
  { print }
  ' docker-bake.hcl > file.tmp && mv file.tmp docker-bake.hcl

# just DRIVERS_VERSION=2022.11.0 update-driver-versions
update-drivers-versions:
  #!/usr/bin/env bash
  set -euxo pipefail
  sed {{ sed_vars }} "s/^DRIVERS_VERSION := .*/DRIVERS_VERSION := \"{{ DRIVERS_VERSION }}\"/g" \
    Justfile
  sed -i '/variable DRIVERS_VERSION/!b;n;c\ \ \ \ default = "{{ DRIVERS_VERSION }}"' docker-bake.hcl
