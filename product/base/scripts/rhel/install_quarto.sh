#!/bin/bash
set -eo pipefail
export DEBIAN_FRONTEND=noninteractive

# Output delimiter
d="===="

usage() {
    echo "Usage:"
    echo "  $0 [OPTIONS]"
    echo ""
    echo "Examples:"
    echo "  # Install Quarto version specified by QUARTO_VERSION environment variable"
    echo "  $0"
    echo "  # Install Quarto 1.3.340"
    echo "  QUARTO_VERSION=1.3.340 $0"
    echo ""
    echo "Options:"
    echo "  -d, --debug         Enable debug output"
    echo "  -h, --help          Print usage and exit"
    echo "      --prefix        Install Quarto to a custom prefix"
    echo "                      Each version of Quarto will have its own subdirectory"
    echo "                      Default: /opt/quarto"
}


# Set defaults
PREFIX="/opt/quarto"

OPTIONS=$(getopt -o hdr: --long help,debug,prefix: -- "$@")
# shellcheck disable=SC2181
if [[ $? -ne 0 ]]; then
    exit 1;
fi

eval set -- "$OPTIONS"
while true; do
    case "$1" in
        -d | --debug)
            set -x
            shift
            ;;
        -h | --help)
            usage
            shift
            exit
            ;;
        --prefix)
            PREFIX="$2"
            shift 2
            ;;
        --) shift;
            break
            ;;
    esac
done

if [ -z "$QUARTO_VERSION" ]; then
    usage
    exit 1
fi

install_quarto() {
    # Check if Quarto is already installed
    # shellcheck disable=SC2086
    if ${PREFIX}/${QUARTO_VERSION}/bin/quarto --version | grep -qE "^${QUARTO_VERSION}" ; then
        echo "$d Quarto $QUARTO_VERSION is already installed in $PREFIX/$QUARTO_VERSION $d"
        return
    fi

    mkdir -p "/opt/quarto/${QUARTO_VERSION}"
    wget -q -O - "https://github.com/quarto-dev/quarto-cli/releases/download/v${QUARTO_VERSION}/quarto-${QUARTO_VERSION}-linux-amd64.tar.gz" | tar xzf - -C "/opt/quarto/${QUARTO_VERSION}" --strip-components=1
}

install_quarto
