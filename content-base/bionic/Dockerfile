# Using dated tags from https://hub.docker.com/_/ubuntu/
FROM ubuntu:bionic

MAINTAINER RStudio Docker <docker@rstudio.com>

# Installation prerequisites --------------------------------------------------#

# curl is used to download things.
# libev-dev is required for most interactive Python applications.
RUN export DEBIAN_FRONTEND=noninteractive && \
        apt-get update \
        && \
        apt-get install -y \
        curl \
        libev-dev \
        && \
        rm -rf /var/lib/apt/lists/*

# System dependencies needed by popular R packages
# https://docs.rstudio.com/rsc/post-setup-tool/#install-system-dependencies

# Now, install the system requirements for R packages.
RUN export DEBIAN_FRONTEND=noninteractive && \
        apt-get update \
        && \
        apt-get install -y \
        default-jdk \
        gdal-bin \
        git \
        imagemagick \
        libcairo2-dev \
        libcurl4-openssl-dev \
        libfontconfig1-dev \
        libfreetype6-dev \
        libfribidi-dev \
        libgdal-dev \
        libgeos-dev \
        libgl1-mesa-dev \
        libglpk-dev \
        libglu1-mesa-dev \
        libgmp3-dev \
        libharfbuzz-dev \
        libicu-dev \
        libjpeg-dev \
        libmagick++-dev \
        libmysqlclient-dev \
        libpng-dev \
        libpq-dev \
        libproj-dev \
        libsodium-dev \
        libssh2-1-dev \
        libssl-dev \
        libtiff-dev \
        libudunits2-dev \
        libv8-dev \
        libxml2-dev \
        make \
        perl \
        tcl \
        tk \
        tk-dev \
        tk-table \
        unixodbc-dev \
        zlib1g-dev \
        && \
        rm -rf /var/lib/apt/lists/*

# Install TinyTeX --------------------------------------------------------------#

# From https://github.com/rstudio/r-docker/blob/master/base/bionic/Dockerfile

RUN export DEBIAN_FRONTEND=noninteractive && \
    apt-get update && \
    apt-get install -y wget && \
    rm -rf /var/lib/apt/lists/* && \
    wget -qO- "https://yihui.org/tinytex/install-bin-unix.sh" | sh && \
    /root/.TinyTeX/bin/*/tlmgr path remove && \
    mv /root/.TinyTeX/ /opt/TinyTeX && \
    /opt/TinyTeX/bin/*/tlmgr option sys_bin /usr/local/bin && \
    /opt/TinyTeX/bin/*/tlmgr path add && \
    rm -rf /var/lib/apt/lists/*

# Install R -------------------------------------------------------------------#

# Reference: https://docs.rstudio.com/resources/install-r/

# We are NOT linking one of these R versions into the PATH.

ARG R_DISTRIBUTION=ubuntu-1804

ARG R_VERSION=3.6.3
ARG R_INSTALLER=r-${R_VERSION}_1_amd64.deb
RUN curl -fsSL -O https://cdn.rstudio.com/r/${R_DISTRIBUTION}/pkgs/${R_INSTALLER} && \
    export DEBIAN_FRONTEND=noninteractive && \
    apt-get update && \
    apt-get install -f -y ./${R_INSTALLER} && \
    rm ${R_INSTALLER} && \
    rm -rf /var/lib/apt/lists/*


# Install Python --------------------------------------------------------------#

# Reference: https://docs.rstudio.com/resources/install-python/

# We are NOT linking one of these Python versions into the PATH.

ARG MINICONDA_VERSION=4.7.12.1
ARG PYTHON_VERSION=3.7.6

# The documented approach uses a particular miniconda install script version
# to obtain the desired Python version. We are first installing miniconda and
# then asking it to install different Python versions.

RUN curl -fsSL -o miniconda.sh https://repo.anaconda.com/miniconda/Miniconda3-${MINICONDA_VERSION}-Linux-x86_64.sh \
    && chmod 755 miniconda.sh \
    && ./miniconda.sh -b -p /opt/miniconda \
    && /opt/miniconda/bin/conda create --quiet --yes --prefix /opt/python/${PYTHON_VERSION} --channel conda-forge python=${PYTHON_VERSION} virtualenv \
    && rm -f miniconda.sh \
    # remove miniconda too, for size
    && rm -rf /opt/miniconda
