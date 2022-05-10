#!/usr/bin/env sh
#
# Print the R, Python, and Quarto installations on this host and the version
# of each.
#

# The R, Python, and Quarto "homes" are locations that are well-known to
# contain multiple installations; one per sub-directory.
#
# The alternate "default" locations often contain an R installation when a
# system has only one version of R.
#
# PATH lookup almost always overlaps one of the R, Python, or Quarto
# installations.
#
# The "python", "python2", and "python3" PATH lookup likely has some overlap.
# On an Ubuntu 16.04 host, for example, /usr/bin/python and /usr/bin/python2
# are both symbolic links to /usr/bin/python2.7.

# With this tool in a "scripts" directory, you can run it within an image with a command like:
# docker run --rm -v $(pwd)/scripts:/scripts rstudio/connect-content-images:kitchen-sink-ubuntu1604 /scripts/examine-image.sh > runtime.yaml
#
# Interpreter configuration is printed to STDOUT, of the form
# <language>:<version>:<interpreter>. Duplicates are possible.
#
# Informational messages are printed to STDERR.
#
# Run with additional debug tracing by setting the DEBUG environment variable:
# docker run -e DEBUG=yes --rm -v $(pwd)/scripts:/scripts rstudio/connect-content-images:kitchen-sink-ubuntu1604 /scripts/examine-image.sh > runtime.yaml


R_HOMES="/opt/R /opt/local/R"
PYTHON_HOMES="/opt/python /opt/local/python"
QUARTO_HOMES="/opt/quarto /opt/local/quarto"

# The alternate R locations are almost always redundant with the PATH and
# R_HOMES search...
#
# ALTERNATE_R_LOCATIONS="
#      /usr/lib/R
#      /usr/lib64/R
#      /usr/local/lib/R
#      /usr/local/lib64/R
#      /opt/local/lib/R
#      /opt/local/lib64/R
# "
ALTERNATE_R_LOCATIONS=""

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

# R ---------------------------------------------------------------------------#

R_FOUND=0
record_r() {
    CANONICAL=$1
    R_VERSION=$2
    R_FOUND=1
    echo "r:${R_VERSION}:${CANONICAL}"
}

r_exe_probe() {
    R_INSTALL=$1
    R_EXE=$2

    # shellcheck disable=SC2016
    R_VERSION=$("${R_EXE}" -s -e 'cat(R.version$major,R.version$minor, sep = ".")' 2>/dev/null)
    status=$?
    if [ ${status} = 0 ] ; then
        CANONICAL=$(readlink -f "${R_EXE}")
        log "Found R at ${R_EXE} in ${R_INSTALL} with with canonical location ${CANONICAL} and version ${R_VERSION}."
        record_r "${CANONICAL}" "${R_VERSION}"
    fi
}

r_install_probe() {
    R_INSTALL=$1

    debug "Probing ${R_INSTALL}"
    R_EXE="${R_INSTALL}/bin/R"
    if [ -x "${R_EXE}" ] ; then
        debug "Have R at ${R_EXE}"
        r_exe_probe "${R_INSTALL}" "${R_EXE}"
    fi
}

for R_HOME in ${R_HOMES} ; do
    debug "${R_HOME}"

    if [ -d "${R_HOME}" ] ; then
        for R_INSTALL in "${R_HOME}"/* ; do
            r_install_probe "${R_INSTALL}"
        done
    fi
done

for R_INSTALL in ${ALTERNATE_R_LOCATIONS} ; do
    r_install_probe "${R_INSTALL}"
done

# Probe R in PATH only when no other R available.
if [ ${R_FOUND} = 0 ] ; then
    R_EXE=$(which R 2>/dev/null)
    status=$?
    if [ ${status} = 0 ] ; then
        r_exe_probe "PATH" "${R_EXE}"
    fi
fi

if [ ${R_FOUND} = 0 ] ; then
    log "Unable to locate an R installation."
fi

# Python ----------------------------------------------------------------------#

PYTHON_FOUND=0
record_python() {
    CANONICAL=$1
    PYTHON_VERSION=$2
    PYTHON_FOUND=1
    echo "python:${PYTHON_VERSION}:${CANONICAL}"
}

python_exe_probe() {
    PYTHON_INSTALL=$1
    PYTHON_EXE=$2
    
    PYTHON_VERSION=$("${PYTHON_EXE}" -E -c 'import sys; print("%d.%d.%d" % sys.version_info[0:3])' 2>/dev/null)
    status=$?
    if [ ${status} = 0 ] ; then
        CANONICAL=$(readlink -f "${PYTHON_EXE}")
        log "Found Python at ${PYTHON_EXE} in ${PYTHON_INSTALL} with canonical location ${CANONICAL} and version ${PYTHON_VERSION}."
        record_python "${CANONICAL}" "${PYTHON_VERSION}"
    fi
}

for PYTHON_HOME in ${PYTHON_HOMES} ; do
    debug "${PYTHON_HOME}"

    if [ -d "${PYTHON_HOME}" ] ; then
        for PYTHON_INSTALL in "${PYTHON_HOME}"/* ; do
            debug "Probing ${PYTHON_INSTALL}"
            PYTHON_EXE="${PYTHON_INSTALL}/bin/python"
            if [ -x "${PYTHON_EXE}" ] ; then
                debug "Have Python at ${PYTHON_EXE}"
                python_exe_probe "${PYTHON_INSTALL}" "${PYTHON_EXE}"
            fi
        done
    fi
done

# Probe Python in PATH only when no other Python available.
if [ ${PYTHON_FOUND} = 0 ] ; then
    PYTHON_EXE=$(which python 2>/dev/null)
    status=$?
    if [ ${status} = 0 ] ; then
        python_exe_probe "PATH" "${PYTHON_EXE}"
    fi
    PYTHON_EXE=$(which python2 2>/dev/null)
    status=$?
    if [ ${status} = 0 ] ; then
        python_exe_probe "PATH" "${PYTHON_EXE}"
    fi
    PYTHON_EXE=$(which python3 2>/dev/null)
    status=$?
    if [ ${status} = 0 ] ; then
        python_exe_probe "PATH" "${PYTHON_EXE}"
    fi
fi

if [ ${PYTHON_FOUND} = 0 ] ; then
    log "Unable to locate a Python installation."
fi

# Quarto ----------------------------------------------------------------------#

QUARTO_FOUND=0
record_quarto() {
    CANONICAL=$1
    QUARTO_VERSION=$2
    QUARTO_FOUND=1
    echo "quarto:${QUARTO_VERSION}:${CANONICAL}"
}

quarto_exe_probe() {
    QUARTO_INSTALL=$1
    QUARTO_EXE=$2

    # shellcheck disable=SC2016
    QUARTO_VERSION=$("${QUARTO_EXE}" --version 2>/dev/null)
    status=$?
    if [ ${status} = 0 ] ; then
        CANONICAL=$(readlink -f "${QUARTO_EXE}")
        log "Found Quarto at ${QUARTO_EXE} in ${QUARTO_INSTALL} with with canonical location ${CANONICAL} and version ${QUARTO_VERSION}."
        record_quarto "${CANONICAL}" "${QUARTO_VERSION}"
    fi
}

quarto_install_probe() {
    QUARTO_INSTALL=$1

    debug "Probing ${QUARTO_INSTALL}"
    QUARTO_EXE="${QUARTO_INSTALL}/bin/quarto"
    if [ -x "${QUARTO_EXE}" ] ; then
        debug "Have Quarto at ${QUARTO_EXE}"
        quarto_exe_probe "${QUARTO_INSTALL}" "${QUARTO_EXE}"
    fi
}

for QUARTO_HOME in ${QUARTO_HOMES} ; do
    debug "${QUARTO_HOME}"

    if [ -d "${QUARTO_HOME}" ] ; then
        # Does QUARTO_HOME=/opt/quarto look like an installation or a
        # directory containing installations?
        if [ -d "${QUARTO_HOME}/bin" ] ; then
            quarto_install_probe "${QUARTO_HOME}"
        else
            for QUARTO_INSTALL in "${QUARTO_HOME}"/* ; do
                quarto_install_probe "${QUARTO_INSTALL}"
            done
        fi
    fi
done

# Probe Quarto in PATH only when no other quarto available.
if [ ${QUARTO_FOUND} = 0 ] ; then
    QUARTO_EXE=$(which quarto 2>/dev/null)
    status=$?
    if [ ${status} = 0 ] ; then
        quarto_exe_probe "PATH" "${QUARTO_EXE}"
    fi
fi

if [ ${QUARTO_FOUND} = 0 ] ; then
    log "Unable to locate a Quarto installation."
fi
