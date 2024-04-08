#!/usr/bin/env just --justfile

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

# just bake connect
bake target:
  just -f {{justfile()}} create-builder || true
  docker buildx bake --builder=posit-builder -f docker-bake.hcl {{target}}

preview-bake target branch="$(git branch --show-current)":
  just -f {{justfile()}} create-builder || true
  WORKBENCH_DAILY_VERSION=$(just -f ci.Justfile get-version workbench --type=daily --local) \
  WORKBENCH_PREVIEW_VERSION=$(just -f ci.Justfile get-version workbench --type=preview --local) \
  PACKAGE_MANAGER_DAILY_VERSION=$(just -f ci.Justfile get-version package-manager --type=daily --local) \
  CONNECT_DAILY_VERSION=$(just -f ci.Justfile get-version connect --type=daily --local) \
  BRANCH="{{branch}}" \
  docker buildx bake --builder=posit-builder -f docker-bake.preview.hcl {{target}}

# just plan
plan:
  docker buildx bake -f docker-bake.hcl --print

preview-plan branch="$(git branch --show-current)":
  WORKBENCH_DAILY_VERSION=$(just -f ci.Justfile get-version workbench --type=daily --local) \
  WORKBENCH_PREVIEW_VERSION=$(just -f ci.Justfile get-version workbench --type=preview --local) \
  PACKAGE_MANAGER_DAILY_VERSION=$(just -f ci.Justfile get-version package-manager --type=daily --local) \
  CONNECT_DAILY_VERSION=$(just -f ci.Justfile get-version connect --type=daily --local) \
  BRANCH="{{branch}}" \
  docker buildx bake -f docker-bake.preview.hcl --print

# just build
build:
  just -f {{justfile()}} bake build

preview-build branch="$(git branch --show-current)":
  WORKBENCH_DAILY_VERSION=$(just -f ci.Justfile get-version workbench --type=daily --local) \
  WORKBENCH_PREVIEW_VERSION=$(just -f ci.Justfile get-version workbench --type=preview --local) \
  PACKAGE_MANAGER_DAILY_VERSION=$(just -f ci.Justfile get-version package-manager --type=daily --local) \
  CONNECT_DAILY_VERSION=$(just -f ci.Justfile get-version connect --type=daily --local) \
  BRANCH="{{branch}}" \
  just -f {{justfile()}} bake preview-build

# just test
test:
  just -f {{justfile()}} bake test
  just -f {{justfile()}} test-connect ubuntu2204

# just preview-test
preview-test branch="$(git branch --show-current)":
  WORKBENCH_DAILY_VERSION=$(just -f ci.Justfile get-version workbench --type=daily --local) \
  WORKBENCH_PREVIEW_VERSION=$(just -f ci.Justfile get-version workbench --type=preview --local) \
  PACKAGE_MANAGER_DAILY_VERSION=$(just -f ci.Justfile get-version package-manager --type=daily --local) \
  CONNECT_DAILY_VERSION=$(just -f ci.Justfile get-version connect --type=daily --local) \
  BRANCH="{{branch}}" \
  just -f {{justfile()}} bake preview-test
  WORKBENCH_DAILY_VERSION=$(just -f ci.Justfile get-version workbench --type=daily --local) \
  WORKBENCH_PREVIEW_VERSION=$(just -f ci.Justfile get-version workbench --type=preview --local) \
  PACKAGE_MANAGER_DAILY_VERSION=$(just -f ci.Justfile get-version package-manager --type=daily --local) \
  CONNECT_DAILY_VERSION=$(just -f ci.Justfile get-version connect --type=daily --local) \
  BRANCH="{{branch}}" \
  just -f {{justfile()}} test-connect-preview ubuntu2204

# just build-test
build-test:
  just -f {{justfile()}} build
  just -f {{justfile()}} test

preview-build-test:
  just -f {{justfile()}} preview-build
  just -f {{justfile()}} preview-test

# Run tests

# just test-connect ubuntu2204
test-connect os="ubuntu2204":
  #!/bin/bash
  just -f {{justfile()}} create-builder || true
  build_cmd=$(python3 {{justfile_directory()}}/tools/bake_test_command_extract.py connect {{os}})
  echo $build_cmd
  if [[ $? -ne 0 ]]; then
    echo "Failed to extract build command"
    exit 1
  fi
  bash -c "$build_cmd"

# just test-connect ubuntu2204
test-connect-preview os="ubuntu2204":
  #!/bin/bash
  set -x
  just -f {{justfile()}} create-builder || true
  build_cmd=$( \
    WORKBENCH_DAILY_VERSION=$(just -f ci.Justfile get-version workbench --type=daily --local) \
    WORKBENCH_PREVIEW_VERSION=$(just -f ci.Justfile get-version workbench --type=preview --local) \
    PACKAGE_MANAGER_DAILY_VERSION=$(just -f ci.Justfile get-version package-manager --type=daily --local) \
    CONNECT_DAILY_VERSION=$(just -f ci.Justfile get-version connect --type=daily --local) \
    python3 {{justfile_directory()}}/tools/bake_test_command_extract.py connect-daily {{os}} --file "docker-bake.preview.hcl" \
  )
  echo $build_cmd
  if [[ $? -ne 0 ]]; then
    echo "Failed to extract build command"
    exit 1
  fi
  bash -c "$build_cmd"
