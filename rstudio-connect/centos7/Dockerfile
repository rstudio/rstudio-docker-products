FROM centos:7

LABEL maintainer="sol-eng@rstudio.com"

# Install R -------------------------------------------------------------------#

ARG R_VERSION=3.6.0

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

# Install RStudio Connect -----------------------------------------------------#

ARG RSC_VERSION=1.7.4.1-7

RUN yum update -y && \
    yum install -y \
    wget \
    which && \
    yum clean all

RUN wget https://s3.amazonaws.com/rstudio-connect/rstudio-connect-${RSC_VERSION}.el.x86_64.rpm && \
    yum install -y --nogpgcheck rstudio-connect-${RSC_VERSION}.el.x86_64.rpm

EXPOSE 3939/tcp

# Locale configuration --------------------------------------------------------#

RUN localedef -i en_US -f UTF-8 en_US.UTF-8
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8

CMD ["/opt/rstudio-connect/bin/connect", "--config", "/etc/rstudio-connect/rstudio-connect.gcfg"]
