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
    echo "  -d, --debug                   Enable debug output"
    echo "  -h, --help                    Print usage and exit"
    echo "      --prefix                  Install Quarto to a custom prefix"
    echo "                                Each version of Quarto will have its own subdirectory"
    echo "                                Default: /opt/quarto"
    echo "      --install-tinytex         Install TinyTeX using Quarto"
    echo "      --add-path-tinytex        Add TinyTeX to PATH using Quarto"
    echo "      --update-tinytex          Update TinyTeX using Quarto"
    echo "      --uninstall-tinytex       Uninstall TinyTeX from Quarto"
}


# Set defaults
PREFIX="/opt/quarto"
QUARTO_PATH="${PREFIX}/${QUARTO_VERSION}/bin/quarto"
ADD_PATH_TINYTEX=0
INSTALL_TINYTEX=0
UPDATE_TINYTEX=0
UNINSTALL_TINYTEX=0
IS_WORKBENCH_INSTALLATION=0

# Set Quarto Path to the bundled version in Workbench if it exists
if [ -f "/lib/rstudio-server/bin/quarto/bin/quarto" ]; then
    QUARTO_PATH="/lib/rstudio-server/bin/quarto/bin/quarto"
    IS_WORKBENCH_INSTALLATION=1
fi

OPTIONS=$(getopt -o hd --long help,debug,prefix:,install-tinytex,add-path-tinytex,update-tinytex,uninstall-tinytex -- "$@")
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
        --install-tinytex)
            INSTALL_TINYTEX=1
            shift
            ;;
        --add-path-tinytex)
            ADD_PATH_TINYTEX=1
            shift
            ;;
        --update-tinytex)
            UPDATE_TINYTEX=1
            shift
            ;;
        --uninstall-tinytex)
            UNINSTALL_TINYTEX=1
            shift
            ;;
        --) shift;
            break
            ;;
    esac
done

if [ -z "$QUARTO_VERSION" ] && [[ "$IS_WORKBENCH_INSTALLATION" -eq 0 ]]; then
    usage
    exit 1
fi

install_quarto() {
    # Check if Quarto is already installed
    # shellcheck disable=SC2086
    if $QUARTO_PATH --version | grep -qE "^${QUARTO_VERSION}" ; then
        echo "$d Quarto $QUARTO_VERSION is already installed in $PREFIX/$QUARTO_VERSION $d"
        return
    fi

    mkdir -p "/opt/quarto/${QUARTO_VERSION}"
    curl -fsSL "https://github.com/quarto-dev/quarto-cli/releases/download/v${QUARTO_VERSION}/quarto-${QUARTO_VERSION}-linux-amd64.tar.gz" | tar xzf - -C "/opt/quarto/${QUARTO_VERSION}" --strip-components=1
}

update_tinytex() {
    $QUARTO_PATH update tinytex --no-prompt
}

uninstall_tinytex() {
    $QUARTO_PATH uninstall tinytex --no-prompt
}

install_tinytex() {
    uninstall_tinytex
    if [[ "$ADD_PATH_TINYTEX" -eq 1 ]]; then
        $QUARTO_PATH install tinytex --update-path --no-prompt
    else
        $QUARTO_PATH install tinytex --no-prompt
    fi
}

if [[ "$IS_WORKBENCH_INSTALLATION" -eq 0 ]]; then
    # Skip installation if Quarto is bundled with Workbench
    install_quarto
fi
if [[ "$INSTALL_TINYTEX" -eq 1 ]]; then
    install_tinytex
fi
if [[ "$UPDATE_TINYTEX" -eq 1 ]]; then
    update_tinytex
fi
if [[ "$UNINSTALL_TINYTEX" -eq 1 ]]; then
    uninstall_tinytex
fi
