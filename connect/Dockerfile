ARG R_VERSION=3.6.2
FROM rstudio/r-base:${R_VERSION}-bionic
LABEL maintainer="RStudio Docker <docker@rstudio.com>"

# Locale configuration --------------------------------------------------------#
RUN localedef -i en_US -f UTF-8 en_US.UTF-8
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8
ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update --fix-missing && apt-get install -y wget bzip2 ca-certificates \
    libglib2.0-0 libxext6 libsm6 libxrender1 gdebi-core libssl1.0.0 libssl-dev

# Install Python  -------------------------------------------------------------#
ARG PYTHON_VERSION=3.6.5
RUN curl -o /tmp/miniconda.sh https://repo.anaconda.com/miniconda/Miniconda3-4.5.4-Linux-x86_64.sh && \
    /bin/bash /tmp/miniconda.sh -b -p /opt/python/${PYTHON_VERSION} && \
    rm /tmp/miniconda.sh && \
    /opt/python/${PYTHON_VERSION}/bin/conda clean -tipsy && \
    ln -s /opt/python/${PYTHON_VERSION}/etc/profile.d/conda.sh /etc/profile.d/conda.sh && \
    echo "PATH=/opt/python/${PYTHON_VERSION}/bin:$PATH" > /etc/profile.d/python.sh && \
    /opt/python/${PYTHON_VERSION}/bin/conda clean -a && \
    /opt/python/${PYTHON_VERSION}/bin/pip install virtualenv
ENV PATH /opt/python/${PYTHON_VERSION}/bin:$PATH

# Install RStudio Connect -----------------------------------------------------#
ARG RSC_VERSION=1.7.8-7
RUN curl -O https://s3.amazonaws.com/rstudio-connect/rstudio-connect_${RSC_VERSION}_amd64.deb && \
    gdebi -n rstudio-connect_${RSC_VERSION}_amd64.deb && \
    rm rstudio-connect_${RSC_VERSION}_amd64.deb

# Runtime settings ------------------------------------------------------------#
ARG TINI_VERSION=0.18.0
RUN curl -L -o /usr/local/bin/tini https://github.com/krallin/tini/releases/download/v${TINI_VERSION}/tini && \
    chmod +x /usr/local/bin/tini

COPY startup.sh /usr/local/bin/startup.sh
RUN chmod +x /usr/local/bin/startup.sh

EXPOSE 3939/tcp
ENV RSC_LICENSE ""
COPY rstudio-connect.gcfg /etc/rstudio-connect/rstudio-connect.gcfg
VOLUME ["/data", "/etc/rstudio-connect/license.lic"]

ENTRYPOINT ["tini", "--"]
CMD ["/usr/local/bin/startup.sh"]
