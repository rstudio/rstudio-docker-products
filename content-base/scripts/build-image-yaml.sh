#!/usr/bin/env bash
#
# Script that runs examine-image.sh against named images and produces
# Launcher.ClusterDefinition YAML that can be read by RStudio Connect.
#
# Run with:
#     ./scripts/build-image-yaml.sh <image> [<image> ...]
#
# Examples:
#     ./scripts/build-image-yaml.sh rstudio/connect-content-images:kitchen-sink-ubuntu16.04
#     ./scripts/build-image-yaml.sh rstudio/content-base:r3.1.3-py2.7.18-bionic
#     ./scripts/build-image-yaml.sh rstudio/content-base:r4.0.5-py3.9.2-bionic
#     ./scripts/build-image-yaml.sh rstudio/content-base:r3.6.3-py3.8.8-bionic rstudio/content-base:r4.1.0-py3.9.2-bionic
#
# Set DEBUG for debugging output:
#     DEBUG=1 ./scripts/build-image-yaml.sh rstudio/connect-content-images:kitchen-sink-ubuntu16.04
#

set -eo pipefail

if [ $# -lt 1 ] ; then
    echo "usage: $0 <image> [<image> ...]"
    exit 1
fi

IMAGES="$@"

SCRIPTS=$(cd "$(dirname "$0")" && pwd)
    
# prints to stderr
log() {
    echo "$@" 1>&2
}

# conditionally prints to stderr
debug() {
    if [ -n "${DEBUG}" ] ; then
        echo "DEBUG($0)" "$@" 1>&2
    fi
}

echo "name: Kubernetes"
echo "images:"

for IMAGE in ${IMAGES} ; do
    TMPFILE=$(mktemp)

    log "Analyzing: ${IMAGE}"
    log "------------------------------------------------------------"
    docker run --rm \
           -e DEBUG=${DEBUG} \
           -v "${SCRIPTS}":/scripts \
           "${IMAGE}" \
           /scripts/examine-image.sh | sort -n | uniq > "${TMPFILE}"

    echo "  -"
    echo "    name: ${IMAGE}"

    R_FOUND=0
    PYTHON_FOUND=0

    # examine-image.sh may produce duplicates; order and uniquify what we have.
    while IFS= read -r line; do
        debug "line: $line"

        language=$(echo "${line}" | awk -F : '{print $1}')
        version=$(echo "${line}" | awk -F : '{print $2}')
        interpreter=$(echo "${line}" | awk -F : '{print $3}')

        if [ "${language}" = "python" ] ; then
            if [ ${PYTHON_FOUND} = 0 ] ; then
                PYTHON_FOUND=1
                echo "    python:"
                echo "      installations:"
            fi
        elif [ "${language}" = "r" ] ; then
            if [ ${R_FOUND} = 0 ] ; then
                R_FOUND=1
                echo "    r:"
                echo "      installations:"
            fi
        fi

        echo "        -"
        echo "          path: ${interpreter}"
        echo "          version: ${version}"

    done < "${TMPFILE}"

    rm "${TMPFILE}"

    log "" # separation from next image.
done

# Some analysis of what scripting languages are available in each base image.
#
# macOS - python 2.7.16, python 3.8.2 (as python3), bash 3.2.57, sh is bash
# ubuntu:16.04 - no python, perl 5.22.1, bash 4.3.48, sh is dash
# ubuntu:18.04 - no python, perl 5.26.1, bash 4.4.20, sh is dash
# ubuntu:20.04 - no python, perl 5.30.0, bash 5.0.17, sh is dash
# centos:centos6 - python=python 2.6.6, no perl, bash 4.1.2, sh is bash
# centos:centos7 - python=python 2.7.5, no perl, bash 4.2.46, sh is bash
# centos:centos8 - no python, no perl, bash 4.4.19, sh is bash
# opensuse/leap:42.3 - no python, perl 5.18.2, bash 4.3.48, sh is bash
# opensuse/leap:15.1 - no python, perl 5.26.1, bash 4.4.23, sh is bash
# opensuse/leap:15.2 - no python, perl 5.26.1, bash 4.4.23, sh is bash
