#!/usr/bin/env just --justfile

alias b := build
alias gv := getversion
alias t := test-image
alias gm := getmatrix
alias p := push-images

build $TYPE $PRODUCT OS $BUILDX="" VERSION="":
    #!/usr/bin/env bash
    set -euxo pipefail
    type="{{TYPE}}"
    if [[ $type == "preview" || $type == "daily" ]]; then
        just build-preview {{TYPE}} {{PRODUCT}} {{OS}} {{VERSION}}
    else
        just build-release {{TYPE}} {{PRODUCT}} {{OS}}
    fi

build-release $TYPE $PRODUCT OS BRANCH=`git branch --show` SHA_SHORT=`git rev-parse --short HEAD`:
    #!/usr/bin/env bash
    set -euxo pipefail
    version=`just getversion $PRODUCT --type=$TYPE --local` 
    safe_version=`echo -n "$version" | sed 's/+/-/g'`
    short_name=""
    rsw_download_url_arg=""
    buildx_args=""
    if [[ "{{PRODUCT}}" == "rstudio-workbench-for-microsoft-azure-ml" ]]; then
        safe_version=`echo -n "$safe_version" | sed 's/^\([0-9]\{4\}\.[0-9]\{2\}\.[0-9]*\).*/\1/g'`
    fi

    if [[ "{{PRODUCT}}" == "workbench" ]]; then
        short_name="RSW"
        rsw_download_url_arg="--build-arg RSW_DOWNLOAD_URL=https://download2.rstudio.org/server/{{OS}}/{{ if OS == "centos7" { "x86_64"} else { "amd64" } }}"
    elif [[ "{{PRODUCT}}" == "connect" ]]; then
        short_name="RSC"
    elif [[ "{{PRODUCT}}" == "package-manager" ]]; then
        short_name="RSPM"
    fi

    if [ "$BUILDX" != "" ]; then
        buildx_args="--cache-from=type=local,src=/tmp/.buildx-cache --cache-to=type=local,dest=/tmp/.buildx-cache"
    fi

    docker buildx --builder=$BUILDX build --load $buildx_args -t rstudio/rstudio-{{PRODUCT}}:{{OS}}-latest \
        -t rstudio/rstudio-{{PRODUCT}}:{{OS}}-"${safe_version}" \
        -t rstudio/rstudio-{{PRODUCT}}:{{OS}}-"${safe_version}"--{{SHA_SHORT}} \
        -t ghcr.io/rstudio/rstudio-{{PRODUCT}}:{{OS}}-latest \
        -t ghcr.io/rstudio/rstudio-{{PRODUCT}}:{{OS}}-"${safe_version}" \
        -t ghcr.io/rstudio/rstudio-{{PRODUCT}}:{{OS}}-"${safe_version}"--{{SHA_SHORT}} \
         --build-arg "${short_name}"_VERSION=$version  ${rsw_download_url_arg} --file=./{{PRODUCT}}/docker/{{OS}}/Dockerfile {{PRODUCT}}

    echo rstudio/rstudio-{{PRODUCT}}:{{OS}}-latest \
        rstudio/rstudio-{{PRODUCT}}:{{OS}}-"${safe_version}" \
        rstudio/rstudio-{{PRODUCT}}:{{OS}}-"${safe_version}"--{{SHA_SHORT}} \
        ghcr.io/rstudio/rstudio-{{PRODUCT}}:{{OS}}-latest \
        ghcr.io/rstudio/rstudio-{{PRODUCT}}:{{OS}}-"${safe_version}" \
        ghcr.io/rstudio/rstudio-{{PRODUCT}}:{{OS}}-"${safe_version}"--{{SHA_SHORT}} 
    

build-preview $TYPE $PRODUCT OS VERSION="" BRANCH=`git branch --show`:
    #!/usr/bin/env bash
    set -euxo pipefail
    version={{ if VERSION == "" { `just getversion $PRODUCT --type=$TYPE --local` } else { VERSION } }}
    safe_version=`echo -n "$version" | sed 's/+/-/g'`
    branch_prefix=""
    rsw_download_url_arg=""
    buildx_args=""
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

    if [ "$BUILDX" != "" ]; then
        buildx_args="--cache-from=type=local,src=/tmp/.buildx-cache --cache-to=type=local,dest=/tmp/.buildx-cache"
    fi

    docker buildx --builder=$BUILDX build --load $buildx_args -t rstudio/rstudio-{{PRODUCT}}-preview:"${branch_prefix}"{{OS}}-"${safe_version}" \
        -t rstudio/rstudio-{{PRODUCT}}-preview:"${branch_prefix}"{{OS}}-{{TYPE}} \
        -t ghcr.io/rstudio/rstudio-{{PRODUCT}}-preview:"${branch_prefix}"{{OS}}-"${safe_version}" \
        -t ghcr.io/rstudio/rstudio-{{PRODUCT}}-preview:"${branch_prefix}"{{OS}}-{{TYPE}} \
         --build-arg "${short_name}"_VERSION=$version ${rsw_download_url_arg} --file=./{{PRODUCT}}/docker/{{OS}}/Dockerfile {{PRODUCT}}

    echo rstudio/rstudio-{{PRODUCT}}-preview:"${branch_prefix}"{{OS}}-"${safe_version}" \
        rstudio/rstudio-{{PRODUCT}}-preview:"${branch_prefix}"{{OS}}-{{TYPE}} \
        ghcr.io/rstudio/rstudio-{{PRODUCT}}-preview:"${branch_prefix}"{{OS}}-"${safe_version}" \
        ghcr.io/rstudio/rstudio-{{PRODUCT}}-preview:"${branch_prefix}"{{OS}}-{{TYPE}}

push-images +IMAGES:
    #!/usr/bin/env bash
    set -euxo pipefail
    for image in {{IMAGES}}
    do
        docker push "${image}"
    done
    

test-image $TYPE $PRODUCT +IMAGES:
    #!/usr/bin/env bash
    set -euxo pipefail
    images="{{IMAGES}}"
    version=`just getversion $PRODUCT --type=$TYPE --local`
    read -ra arr <<<"$images"
    cd ./{{PRODUCT}} && IMAGE_NAME="${arr[0]}" RSW_VERSION="$version" RSC_VERSION="$version" RSPM_VERSION="$version" docker-compose -f docker-compose.test.yml run sut    
    
getversion +NARGS:
    ./get-version.py {{NARGS}}

getmatrix *NARGS:
    ./get-matrix.py {{NARGS}}

test A B:
    echo "{{A}} {{B}}"