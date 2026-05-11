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
    echo "  # Install Node.js version specified by NODEJS_VERSION environment variable"
    echo "  $0"
    echo "  # Install Node.js 22.22.2"
    echo "  NODEJS_VERSION=22.22.2 $0"
    echo ""
    echo "Options:"
    echo "  -d, --debug         Enable debug output"
    echo "  -h, --help          Print usage and exit"
    echo "      --prefix        Install Node.js to a custom prefix"
    echo "                      Each version of Node.js will have its own subdirectory"
    echo "                      Default: /opt/nodejs"
}

# Set defaults
PREFIX="/opt/nodejs"

OPTIONS=$(getopt -o hd --long help,debug,prefix: -- "$@")
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

if [ -z "$NODEJS_VERSION" ]; then
    usage
    exit 1
fi

# Set node binary path
NODE_BIN="${PREFIX}/${NODEJS_VERSION}/bin/node"

install_node() {
    # Check if Node.js is already installed at the requested version.
    if [ -x "$NODE_BIN" ] && "$NODE_BIN" --version | grep -qE "^v${NODEJS_VERSION}$"; then
        echo "$d Node.js $NODEJS_VERSION is already installed in $PREFIX/$NODEJS_VERSION $d"
        return
    fi

    echo "$d$d Installing Node.js $NODEJS_VERSION to $PREFIX/$NODEJS_VERSION $d$d"
    mkdir -p "$PREFIX/$NODEJS_VERSION"

    local tarball="node-v${NODEJS_VERSION}-linux-x64.tar.xz"
    local base_url="https://nodejs.org/dist/v${NODEJS_VERSION}"

    curl -fsSL -o "/tmp/${tarball}" "${base_url}/${tarball}"
    curl -fsSL -o /tmp/SHASUMS256.txt "${base_url}/SHASUMS256.txt"

    # Verify checksum: extract just our tarball's line and pipe to sha256sum -c.
    (cd /tmp && grep " ${tarball}\$" SHASUMS256.txt | sha256sum -c -)

    tar -xJf "/tmp/${tarball}" -C "$PREFIX/$NODEJS_VERSION" --strip-components=1

    rm -f "/tmp/${tarball}" /tmp/SHASUMS256.txt
}

install_node
