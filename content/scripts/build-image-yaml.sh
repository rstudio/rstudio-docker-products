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
# Set NO_PATH_LOOKUPS to ignore PATH-based lookups:
#     NO_PATH_LOOKUPS=1 ./scripts/build-image-yaml.sh rstudio/connect-content-images:kitchen-sink-ubuntu16.04
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
           -e DEBUG="${DEBUG}" \
           -e NO_PATH_LOOKUPS="${NO_PATH_LOOKUPS}" \
           -v "${SCRIPTS}":/scripts \
           "${IMAGE}" \
           /scripts/examine-image.sh | sort -n | uniq > "${TMPFILE}"

    echo "  -"
    echo "    name: ${IMAGE}"

    R_FOUND=0
    PYTHON_FOUND=0
    QUARTO_FOUND=0

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
        elif [ "${language}" = "quarto" ] ; then
            if [ ${QUARTO_FOUND} = 0 ] ; then
                QUARTO_FOUND=1
                echo "    quarto:"
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
