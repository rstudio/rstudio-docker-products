FROM ubuntu:bionic

LABEL maintainer="sol-eng@rstudio.com"

# Set versions
ARG RSP_VERSION=1.2.1335-1
ARG R_VERSION=3.6.0

# Install RStudio Server Pro --------------------------------------------------#

RUN apt-get update -y && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y \
    gdebi-core \
    wget

RUN wget https://download2.rstudio.org/server/trusty/amd64/rstudio-server-pro-${RSP_VERSION}-amd64.deb && \
    gdebi rstudio-connect_${RSPM_VERSION}_amd64.deb

EXPOSE 3939/tcp

# Install R -------------------------------------------------------------------#

RUN sed -Ei 's/^# deb-src /deb-src /' /etc/apt/sources.list && \
    apt-get update -y && \
    DEBIAN_FRONTEND=noninteractive apt-get build-dep -y r-base

RUN mkdir -p /opt/R && \
    cd /opt/R && \
    wget https://cran.rstudio.com/src/base/R-3/R-${R_VERSION}.tar.gz && \
    tar zxvf R-${R_VERSION}.tar.gz && \
    cd R-${R_VERSION}  && \
    ./configure --prefix=/opt/R/${R_VERSION} --enable-memory-profiling --enable-R-shlib --with-blas --with-lapack && \
    make && \
    make install && \
    rm -rf /opt/R/R-${R_VERSION}.tar.gz && \
    rm -rf /opt/R/R-${R_VERSION}

ENV PATH="/opt/R/${R_VERSION}/bin:${PATH}"

# Locale configuration --------------------------------------------------------#

RUN apt-get update -y && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y locales
RUN locale-gen en_US.UTF-8
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8

ENTRYPOINT ["/opt/rstudio-connect/bin/connect", "--config", "/etc/rstudio-connect/rstudio-connect.gcfg"]
