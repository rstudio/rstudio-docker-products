#!/bin/bash
set -eo pipefail
export DEBIAN_FRONTEND=noninteractive

# Output delimiter
d="===="

usage() {
    echo "Usage:"
    echo "  $0 [OPTIONS] [COMMAND [ARG...]]"
    echo ""
    echo "Options:"
    echo "  -d, --debug         Enable debug output"
    echo "  -h, --help          Print usage and exit"
    echo "      --clean         Clean apt cache (apt-get clean)"
    echo "      --update        Update apt cache (apt-get update)"
    echo ""
    echo "Commands:"
    echo "  install <packages>  Install packages (apt-get install)"
    echo "  upgrade             Upgrade all packages (apt-get upgrade)"
}

# Set defaults
APT_ARGS="-o DPkg::Lock::Timeout=60 -y -qq"
CLEAN=0
UPDATE=0

OPTIONS=$(getopt -o hd --long debug,help,clean,update -- "$@")
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
        --clean)
            CLEAN=1
            shift
            ;;
        --update)
            UPDATE=1
            shift
            ;;
        --)
            shift
            break
            ;;
        *)
            echo "Unexpected option: $1"
            exit 1
            ;;
    esac
done

# Wait for apt to be done before continuing
# The Deep learning AMI runs an extremely long apt update-install on first boot.
echo "$d Waiting for apt to finish $d"

# lsof is not installed by default in all images
# We install lsof if it is not already installed, but we don't want the check
# to fail when we invoke this script to install lsof. Chicken & egg problem.
if command -v lsof >/dev/null; then
    lsof_result="\$(lsof /var/lib/apt/lists/lock)"
else
    lsof_result=""
fi
sleep 10
while [ -n "$lsof_result" ] && [ "$(lslocks | grep "apt")" != "" ]; do
    sleep 10
done

# Clean apt cache
if [ "$CLEAN" -eq 1 ]; then
    echo "$d Cleaning apt cache $d"
    # shellcheck disable=SC2086
    apt-get clean $APT_ARGS
    rm -rf /var/lib/apt/lists/*
fi

# Update apt cache
if [ "$UPDATE" -eq 1 ]; then
    echo "$d Updating apt cache $d"
    # shellcheck disable=SC2086
    apt-get update --fix-missing $APT_ARGS
fi

case "$1" in
    install)
        shift
        echo "$d$d Installing apt packages $d$d"
        # shellcheck disable=SC2086
        apt-get install $APT_ARGS "$@"
        ;;
    upgrade)
        echo "$d$d Upgrading apt packages $d$d"
        # shellcheck disable=SC2086
        apt-get upgrade $APT_ARGS
        # shellcheck disable=SC2086
        apt-get dist-upgrade $APT_ARGS
        ;;
    *)
        # Allow clean, update to be used as commands
        if [ "$UPDATE" -eq 1 ] || [ "$CLEAN" -eq 1 ]; then
            exit 0
        fi
        usage
        exit 1
        ;;
esac
