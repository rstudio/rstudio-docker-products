FROM centos:7

LABEL maintainer="sol-eng@rstudio.com"

# Set versions
ARG RSP_VERSION=1.2.1335-1
ARG R_VERSION=3.6.0

# Install RStudio Server Pro --------------------------------------------------#

RUN yum update -y && \
    yum install -y \
    wget && \
    yum clean all

RUN wget https://download2.rstudio.org/server/centos6/x86_64/rstudio-server-rhel-${RSP_VERSION}-x86_64.rpm && \
    yum install -y --nogpgcheck rstudio-connect-${RSC_VERSION}.el.x86_64.rpm

EXPOSE 8787/tcp

# Install R -------------------------------------------------------------------#

RUN yum update -y && \
    yum install -y epel-release make gcc gcc-c++ && \
    yum install -y yum-utils && \
    yum-builddep -y R && \
    yum clean all

RUN mkdir -p /opt/R && \
    cd /opt/R && \
    wget https://cran.rstudio.com/src/base/R-3/R-${R_VERSION}.tar.gz && \
    tar -zxvf R-${R_VERSION}.tar.gz && \
    cd R-${R_VERSION} && \
    ./configure --prefix=/opt/R/${R_VERSION} --enable-memory-profiling --enable-R-shlib --with-blas --with-lapack && \
    make && \
    make install && \
    rm -rf /opt/R/R-${R_VERSION}.tar.gz && \
    rm -rf /opt/R/R-${R_VERSION}

ENV PATH="/opt/R/${R_VERSION}/bin:${PATH}"

# Locale configuration --------------------------------------------------------#

RUN localedef -i en_US -f UTF-8 en_US.UTF-8
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8

ENTRYPOINT ["/usr/lib/rstudio-server/bin/rserver"]
