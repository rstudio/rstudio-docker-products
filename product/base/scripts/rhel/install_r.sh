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
    echo "  # Install R version specified by R_VERSION environment variable"
    echo "  $0"
    echo "  # Install R 4.1.2"
    echo "  R_VERSION=4.1.2 $0"
    echo "  # Install R 4.2.3 and packages listed in /tmp/r_packages.txt"
    echo "  R_VERSION=4.2.3 $0 -r /tmp/r_packages.txt"
    echo ""
    echo "Options:"
    echo "  -d, --debug         Enable debug output"
    echo "  -h, --help          Print usage and exit"
    echo "      --prefix        Install R to a custom prefix"
    echo "                      Each version of R will have its own subdirectory"
    echo "                      Default: /opt/R"
    echo "      --r-exists      Expect R version to already be installed"
    echo "  -r, --requirement <file>"
    echo "                      Install R packages from a requirements file"
    echo "      --with-source   Also download the R source code"
}


# Set defaults
if [ -z "${DISTRO}" ]; then
    DISTRO=$(lsb_release -is | tr '[:upper:]' '[:lower:]')
fi
if [ -z "${OS_VERSION}" ]; then
    OS_VERSION=$(rpm -E %{rhel})
fi
YUM_ARGS="-y -q"
PREFIX="/opt/R"
R_EXISTS=0
WITH_SOURCE=0

OPTIONS=$(getopt -o hdr: --long help,debug,distro:,prefix:,r-exists,requirement:,with-source -- "$@")
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
        --r-exists)
            R_EXISTS=1
            shift
            ;;
        -r | --requirement)
            R_PKG_FILE="$2"
            shift 2
            ;;
        --with-source)
            WITH_SOURCE=1
            shift
            ;;
        --) shift;
            break
            ;;
    esac
done

if [ -z "$R_VERSION" ]; then
    usage
    exit 1
fi

# Set R binary path
R_BIN="${PREFIX}/${R_VERSION}/bin/R"

# Set yum options
YUM_ARGS="-y -q"

install_r() {
    echo "$d$d Installing R $R_VERSION to $PREFIX/$R_VERSION $d$d"
    mkdir -p "$PREFIX"

    local r_url="https://cdn.rstudio.com/r/${DISTRO}-${OS_VERSION}/pkgs/R-${R_VERSION}-1-1.x86_64.rpm"
    curl -sL "$r_url" -o "/tmp/r-${R_VERSION}.rpm"

    # shellcheck disable=SC2086
    yum install $YUM_ARGS "/tmp/r-${R_VERSION}.rpm"
    rm "/tmp/r-${R_VERSION}.rpm"
}

install_r_dependencies() {
    # RHEL installs are more straightforward than Ubuntu. Installing epel-release should cover us well.
    local r_deps="epel-release"

    # Check whether dependencies are already installed
    # shellcheck disable=2086
    if rpm -q $r_deps >/dev/null 2>&1 ; then
        echo "$d R dependencies already installed $d"
        return
    fi

    echo "$d$d Installng R depencencies $d$d"

    # Install R dependencies
    # shellcheck disable=2086
    yum install $YUM_ARGS epel-release
}

install_r_packages() {
    if [ ! -f "$R_PKG_FILE" ]; then
        echo "$d R package file $R_PKG_FILE does not exist $d"
        exit 1
    fi

    echo "$d$d Installing R-${R_VERSION} packages from ${R_PKG_FILE} $d$d"
    local cran_repo="https://packagemanager.rstudio.com/cran/__linux__/${DISTRO}${OS_VERSION}/latest"

    $R_BIN --vanilla --no-echo <<EOF > /dev/null
install.packages(readLines("$R_PKG_FILE"), repos = "$cran_repo")
EOF

}

get_r_source() {
    local r_prefix=${R_VERSION:0:1}
    local r_source_dir="/opt/r-sources"
    local r_source_url="https://cloud.r-project.org/src/base/R-${r_prefix}/R-${R_VERSION}.tar.gz"

    echo "$d Fetching R-${R_VERSION} source code into $r_source_dir $d"
    mkdir -p "$r_source_dir"

    curl -sL "$r_source_url" -o "$r_source_dir/R-${R_VERSION}.tar.gz"
}


# Only add the dependencies if we don't expect R to exist
if [ "$R_EXISTS" -eq 0 ]; then
    install_r_dependencies
fi

# Check if R is already installed
if $R_BIN --version | grep -qE "^R version ${R_VERSION}" ; then
    echo "$d R $R_VERSION is already installed in $PREFIX/$R_VERSION $d"
elif [ "$R_EXISTS" -eq 1 ]; then
    echo "$d R $R_VERSION is not installed in $PREFIX/$R_VERSION $d"
    exit 1
else
    install_r
fi

if [ -n "$R_PKG_FILE" ]; then
    install_r_packages
fi
if [ "$WITH_SOURCE" -eq 1 ]; then
    get_r_source
fi
