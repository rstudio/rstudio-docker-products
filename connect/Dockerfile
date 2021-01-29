ARG R_VERSION=4.0.2
FROM rstudio/r-base:${R_VERSION}-bionic
LABEL maintainer="RStudio Docker <docker@rstudio.com>"

# Locale configuration --------------------------------------------------------#
RUN localedef -i en_US -f UTF-8 en_US.UTF-8
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8
ENV DEBIAN_FRONTEND=noninteractive

# hadolint ignore=DL3008,DL3009
RUN apt-get update --fix-missing \
    && apt-get install -y --no-install-recommends \
        wget \
        bzip2 \
        ca-certificates \
        libglib2.0-0 \
        libxext6 \
        libsm6 \
        libxrender1 \
        gdebi-core \
        libssl1.0.0 \
        libssl-dev git \
	sudo \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Install Python  -------------------------------------------------------------#
ARG PYTHON_VERSION=3.7.7
RUN mkdir /opt/python && \
    curl -fsSL -o /opt/python/miniconda.sh https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh  && \
    chmod 755 /opt/python/miniconda.sh && \
    /opt/python/miniconda.sh -b -p /opt/python/miniconda && \
    /opt/python/miniconda/bin/conda create --quiet --yes --prefix /opt/python/"${PYTHON_VERSION}" --channel conda-forge python="${PYTHON_VERSION}"
RUN /opt/python/${PYTHON_VERSION}/bin/pip install 'virtualenv<20' && \
    /opt/python/${PYTHON_VERSION}/bin/pip install --upgrade setuptools
ENV PATH /opt/python/${PYTHON_VERSION}/bin:$PATH

# Runtime settings ------------------------------------------------------------#
ARG TINI_VERSION=0.18.0
RUN curl -L -o /usr/local/bin/tini https://github.com/krallin/tini/releases/download/v${TINI_VERSION}/tini && \
    chmod +x /usr/local/bin/tini

COPY startup.sh /usr/local/bin/startup.sh
RUN chmod +x /usr/local/bin/startup.sh

# Download RStudio Connect -----------------------------------------------------#
ARG RSC_VERSION=1.8.6.1
RUN apt-get update --fix-missing \
    && curl -L -o rstudio-connect.deb https://cdn.rstudio.com/connect/$(echo $RSC_VERSION | sed -r 's/([0-9]\.[0-9]\.[0-9])(-dev)?[-\.0-9]*/\1/')/rstudio-connect_${RSC_VERSION}~ubuntu18_amd64.deb \
    && gdebi -n rstudio-connect.deb \
    && rm -rf rstudio-connect.deb \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Download and add drivers 
ARG DRIVERS_VERSION=1.6.1
RUN apt-get update -y && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y unixodbc unixodbc-dev gdebi && \
    rm -rf /var/lib/apt/lists/*

RUN curl -O https://drivers.rstudio.org/7C152C12/installer/rstudio-drivers_${DRIVERS_VERSION}_amd64.deb && \
    apt-get update && \
    DEBIAN_FRONTEND=noninteractive gdebi --non-interactive rstudio-drivers_${DRIVERS_VERSION}_amd64.deb && \
    rm -rf /var/lib/apt/lists/* && \
    cp /opt/rstudio-drivers/odbcinst.ini.sample /etc/odbcinst.ini

EXPOSE 3939/tcp
ENV RSC_LICENSE ""
ENV RSC_LICENSE_SERVER ""
COPY rstudio-connect.gcfg /etc/rstudio-connect/rstudio-connect.gcfg
VOLUME ["/data"]

ENTRYPOINT ["tini", "--"]
CMD ["/usr/local/bin/startup.sh"]
