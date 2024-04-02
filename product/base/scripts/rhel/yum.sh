#!/bin/bash
set -eo pipefail

# Output delimiter
d="===="

usage() {
    echo "Usage:"
    echo "  $0 [OPTIONS] [COMMAND [ARG...]]"
    echo ""
    echo "Options:"
    echo "  -d, --debug         Enable debug output"
    echo "  -h, --help          Print usage and exit"
    echo "      --clean         Clean yum cache (yum clean all)"
    echo "      --update        Update yum cache (yum check-update)"
    echo ""
    echo "Commands:"
    echo "  install <packages>  Install packages (yum install)"
    echo "  upgrade             Upgrade all packages (yum upgrade)"
}

# Set defaults
YUM_ARGS="-y -q"
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

# Wait for yum to be done before continuing
# The Deep learning AMI runs an extremely long yum update-install on first boot.
echo "$d Waiting for yum to finish $d"

# lsof is not installed by default in all images
# We install lsof if it is not already installed, but we don't want the check
# to fail when we invoke this script to install lsof. Chicken & egg problem.
if command -v lsof >/dev/null; then
    lsof_result="\$(lsof /var/run/yum.pid)"
else
    lsof_result=""
fi
sleep 10
while [ -n "$lsof_result" ] && [ "$(lslocks | grep "yum")" != "" ]; do
    sleep 10
done

# Clean yum cache
if [ "$CLEAN" -eq 1 ]; then
    echo "$d Cleaning yum cache $d"
    yum clean all $YUM_ARGS
fi

# Update yum cache
if [ "$UPDATE" -eq 1 ]; then
    echo "$d Updating yum cache $d"
    yum update $YUM_ARGS
fi

case "$1" in
    install)
        shift
        echo "$d$d Installing yum packages $d$d"
        # shellcheck disable=SC2086
        yum install $YUM_ARGS "$@"
        ;;
    upgrade)
        echo "$d$d Upgrading yum packages $d$d"
        # shellcheck disable=SC2086
        yum upgrade $YUM_ARGS
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
