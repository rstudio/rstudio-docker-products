#!/usr/bin/env just --justfile

alias b := build
alias gv := getversion
alias t := test-image
alias gm := getmatrix

build $TYPE $PRODUCT OS VERSION="":
    #!/usr/bin/env bash
    set -euxo pipefail
    type="{{TYPE}}"
    if [[ $type == "preview" || $type == "daily" ]]; then
        just build-preview {{TYPE}} {{PRODUCT}} {{OS}} {{VERSION}}
    else
        echo "here"
    fi
    

build-preview $TYPE $PRODUCT OS VERSION="" BRANCH=`git branch --show`:
    #!/usr/bin/env bash
    set -euxo pipefail
    version={{ if VERSION == "" { `just gv $PRODUCT --type=$TYPE --local` } else { VERSION } }}
    safe_version=`echo -n "$version" | sed 's/+/-/g'`
    branch_prefix=""
    rsw_download_url_arg=""
    if [[ "{{BRANCH}}" == "dev" ]]; then
        branch_prefix="dev-"
    elif [[ "{{BRANCH}}" == "dev-rspm" ]]; then
        branch_prefix="dev-rspm-"
    fi

    if [[ "{{PRODUCT}}" == "workbench" ]]; then
        short_name="RSW"
        rsw_download_url_arg="--build-arg RSW_DOWNLOAD_URL=https://s3.amazonaws.com/rstudio-ide-build/server/{{OS}}/{{ if OS == "centos7" { "x86_64"} else { "amd64" } }}"
    elif [[ "{{PRODUCT}}" == "connect" ]]; then
        short_name="RSC"
    elif [[ "{{PRODUCT}}" == "package-manager" ]]; then
        short_name="RSPM"
    fi

    docker build -t rstudio/rstudio-{{PRODUCT}}-preview:"${branch_prefix}"{{OS}}-"${safe_version}" \
        -t rstudio/rstudio-{{PRODUCT}}-preview:"${branch_prefix}"{{OS}}-{{TYPE}} \
        -t ghcr.io/rstudio/rstudio-{{PRODUCT}}-preview:"${branch_prefix}"{{OS}}-"${safe_version}" \
        -t ghcr.io/rstudio/rstudio-{{PRODUCT}}-preview:"${branch_prefix}"{{OS}}-{{TYPE}} \
         --build-arg "${short_name}"_VERSION=$version ${rsw_download_url_arg} --file=./{{PRODUCT}}/docker/{{OS}}/Dockerfile {{PRODUCT}}

    echo rstudio/rstudio-{{PRODUCT}}-preview:"${branch_prefix}"{{OS}}-"${safe_version}"

build-release $TYPE $PRODUCT OS VERSION="" BRANCH=`git branch --show`:
    #!/usr/bin/env bash

test-image PRODUCT IMAGE:
    cd ./{{PRODUCT}} && IMAGE_NAME={{IMAGE}} docker-compose -f docker-compose.test.yml run sut
    

getversion +NARGS:
    ./get-version.py {{NARGS}}

getmatrix *NARGS:
    ./get-matrix.py {{NARGS}}