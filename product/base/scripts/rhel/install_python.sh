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
    echo "  # Install Python version specified by PYTHON_VERSION environment variable"
    echo "  $0"
    echo "  # Install Python 3.10.4"
    echo "  PYTHON_VERSION=3.10.4 $0"
    echo "  # Install Python and packages listed in /tmp/pythonh_packages.txt"
    echo "  PYTHON_VERSION=3.11.1 $0 -r /tmp/r_packages.txt"
    echo ""
    echo "Options:"
    echo "  -d, --debug         Enable debug output"
    echo "  -h, --help          Print usage and exit"
    echo "      --prefix        Install Python to a custom prefix"
    echo "                      Each version of Python will have its own subdirectory"
    echo "                      Default: /opt/python"
    echo "  -r, --requirement <file>"
    echo "                      Install python packages from a requirements file"
}


# Set defaults
if [ -z "${DISTRO}" ]; then
    DISTRO=$(lsb_release -is | tr '[:upper:]' '[:lower:]')
fi
if [ -z "${OS_VERSION}" ]; then
    OS_VERSION=$(rpm -E %{rhel})
fi
YUM_ARGS="-y -q"
PREFIX="/opt/python"

OPTIONS=$(getopt -o hdr: --long help,debug,prefix:,requirement: -- "$@")
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
        -r | --requirement)
            PYTHON_PKG_FILE="$2"
            shift 2
            ;;
        --) shift;
            break
            ;;
    esac
done

if [ -z "$PYTHON_VERSION" ]; then
    usage
    exit 1
fi

# Set python binary path
PYTHON_BIN="${PREFIX}/${PYTHON_VERSION}/bin/python"

# Set yum options
YUM_ARGS="-y -q"

install_python() {
    # Check if Python is already installed
    if $PYTHON_BIN --version | grep -qE "^Python ${PYTHON_VERSION}" ; then
        echo "$d Python $PYTHON_VERSION is already installed in $PREFIX/$PYTHON_VERSION $d"
        return
    fi

    echo "$d$d Installing Python $PYTHON_VERSION to $PREFIX/$PYTHON_VERSION $d$d"
    mkdir -p "$PREFIX"

    local python_url="https://cdn.rstudio.com/python/${DISTRO}-${OS_VERSION}/pkgs/python-${PYTHON_VERSION}-1-1.x86_64.rpm"
    curl -sL "$python_url" -o "/tmp/python-${PYTHON_VERSION}.rpm"

    # shellcheck disable=SC2086
    yum install $YUM_ARGS "/tmp/python-${PYTHON_VERSION}.rpm"
    rm "/tmp/python-${PYTHON_VERSION}.rpm"
    # Upgrade pip to latest version
    $PYTHON_BIN -m pip install -U pip
}

install_python_packages() {
    if [ ! -f "$PYTHON_PKG_FILE" ]; then
        echo "$d Python package file $PYTHON_PKG_FILE does not exist $d"
        exit 1
    fi

    echo "$d$d Installing python-${PYTHON_VERSION} packages from ${PYTHON_PKG_FILE} $d$d"
    $PYTHON_BIN -m pip install -U pip
    $PYTHON_BIN -m pip install -r "$PYTHON_PKG_FILE"
}

install_python
if [ -n "$PYTHON_PKG_FILE" ]; then
    install_python_packages
fi
