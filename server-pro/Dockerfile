ARG R_VERSION=3.6
FROM rstudio/r-base:${R_VERSION}-bionic
LABEL maintainer="RStudio Docker <docker@rstudio.com>"

# Locale configuration --------------------------------------------------------#
RUN localedef -i en_US -f UTF-8 en_US.UTF-8
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8
ENV DEBIAN_FRONTEND=noninteractive

# hadolint ignore=DL3008,DL3009
RUN apt-get update --fix-missing && apt-get install -y --no-install-recommends \
        bzip2 \
        ca-certificates \
        gdebi-core \
        git \
        libglib2.0-0 \
        libxext6 \
        libsm6 \
        libxrender1 \
        libssl1.0.0 \
        libssl-dev \
        openssh-client \
        wget

# Install Python  -------------------------------------------------------------#
ARG PYTHON_VERSION=3.6.5
RUN curl -o /tmp/miniconda.sh https://repo.anaconda.com/miniconda/Miniconda3-4.5.4-Linux-x86_64.sh && \
    /bin/bash /tmp/miniconda.sh -b -p /opt/python/${PYTHON_VERSION} && \
    rm /tmp/miniconda.sh && \
    /opt/python/${PYTHON_VERSION}/bin/conda clean -tipsy && \
    /opt/python/${PYTHON_VERSION}/bin/conda clean -a && \
    /opt/python/${PYTHON_VERSION}/bin/pip install virtualenv

# Install other Python PyPi packages
RUN /opt/python/${PYTHON_VERSION}/bin/pip install --no-cache-dir \
                pip==20.0.2 \
                jupyter==1.0.0 \
                jupyterlab==2.1.0 \
                rsp_jupyter==1.2.5003 \
                rsconnect_jupyter==1.3.3.1

# Install Jupyter extensions
RUN /opt/python/${PYTHON_VERSION}/bin/jupyter-nbextension install --sys-prefix --py rsp_jupyter && \
    /opt/python/${PYTHON_VERSION}/bin/jupyter-nbextension enable --sys-prefix --py rsp_jupyter && \
    /opt/python/${PYTHON_VERSION}/bin/jupyter-nbextension install --sys-prefix --py rsconnect_jupyter && \
    /opt/python/${PYTHON_VERSION}/bin/jupyter-nbextension enable --sys-prefix --py rsconnect_jupyter && \
    /opt/python/${PYTHON_VERSION}/bin/jupyter-serverextension enable --sys-prefix --py rsconnect_jupyter

# Runtime settings ------------------------------------------------------------#
ARG TINI_VERSION=0.18.0
RUN curl -L -o /usr/local/bin/tini https://github.com/krallin/tini/releases/download/v${TINI_VERSION}/tini && \
    chmod +x /usr/local/bin/tini

RUN curl -L -o /usr/local/bin/wait-for-it.sh https://raw.githubusercontent.com/vishnubob/wait-for-it/master/wait-for-it.sh && \
    chmod +x /usr/local/bin/wait-for-it.sh

# Set default env values
ENV RSP_LICENSE ""
ENV RSP_LICENSE_SERVER ""
ENV RSP_TESTUSER rstudio
ENV RSP_TESTUSER_PASSWD rstudio
ENV RSP_TESTUSER_UID 10000
ENV RSP_LAUNCHER true
ENV RSP_LAUNCHER_TIMEOUT 10

# Copy config and startup
COPY startup.sh /usr/local/bin/startup.sh
RUN chmod +x /usr/local/bin/startup.sh
COPY conf/* /etc/rstudio/

# Install RStudio Server Pro --------------------------------------------------#
ARG RSP_VERSION=1.2.5042-1
ARG RSP_DOWNLOAD_URL=https://download2.rstudio.org/server/trusty/amd64
RUN curl -O ${RSP_DOWNLOAD_URL}/rstudio-server-pro-${RSP_VERSION}-amd64.deb \
    && gdebi --non-interactive rstudio-server-pro-${RSP_VERSION}-amd64.deb \
    && rm rstudio-server-pro-${RSP_VERSION}-amd64.deb \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Create log dir
RUN mkdir -p /var/lib/rstudio-server/monitor/log && \
    chown -R rstudio-server:rstudio-server /var/lib/rstudio-server/monitor

EXPOSE 8787/tcp
EXPOSE 5559/tcp

ENTRYPOINT ["tini", "--"]
CMD ["/usr/local/bin/startup.sh"]
