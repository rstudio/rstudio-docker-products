ARG R_VERSION=3.6
FROM rstudio/r-base:${R_VERSION}-centos7
LABEL maintainer="sol-eng@rstudio.com"

# Locale configuration --------------------------------------------------------#
RUN localedef -i en_US -f UTF-8 en_US.UTF-8
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8

# Install Python  -------------------------------------------------------------#
RUN yum install -y \
    bzip2 \
    ca-certificates && \
    yum clean all

RUN curl -o /tmp/miniconda.sh https://repo.anaconda.com/miniconda/Miniconda3-4.5.4-Linux-x86_64.sh && \
    /bin/bash /tmp/miniconda.sh -b -p /opt/python/3.6.5 && \
    rm /tmp/miniconda.sh && \
    /opt/python/3.6.5/bin/conda clean -tipsy && \
    ln -s /opt/python/3.6.5/etc/profile.d/conda.sh /etc/profile.d/conda.sh && \
    /opt/python/3.6.5/bin/conda clean -a && \
    /opt/python/3.6.5/bin/pip install virtualenv

# Install other Python deps
RUN /opt/python/3.6.5/bin/pip install jupyter jupyterlab rsp_jupyter rsconnect_jupyter && \
    /opt/python/3.6.5/bin/jupyter-nbextension install --sys-prefix --py rsp_jupyter && \
    /opt/python/3.6.5/bin/jupyter-nbextension enable --sys-prefix --py rsp_jupyter && \
    /opt/python/3.6.5/bin/jupyter-nbextension install --sys-prefix --py rsconnect_jupyter && \
    /opt/python/3.6.5/bin/jupyter-nbextension enable --sys-prefix --py rsconnect_jupyter && \
    /opt/python/3.6.5/bin/jupyter-serverextension enable --sys-prefix --py rsconnect_jupyter

# Install RStudio Server Pro --------------------------------------------------#
ARG RSP_VERSION=1.2.5001-3
RUN wget https://s3.amazonaws.com/rstudio-ide-build/server/centos6/x86_64/rstudio-server-rhel-pro-${RSP_VERSION}-x86_64.rpm && \
    yum install -y --nogpgcheck sysvinit-tools rstudio-server-rhel-pro-${RSP_VERSION}-x86_64.rpm && \
    rm rstudio-server-rhel-pro-${RSP_VERSION}-x86_64.rpm

# Runtime settings ------------------------------------------------------------#
ARG TINI_VERSION=0.18.0
RUN curl -L -o /usr/local/bin/tini https://github.com/krallin/tini/releases/download/v${TINI_VERSION}/tini && \
    chmod +x /usr/local/bin/tini

RUN curl -L -o /usr/local/bin/wait-for-it.sh https://raw.githubusercontent.com/vishnubob/wait-for-it/master/wait-for-it.sh && \
    chmod +x /usr/local/bin/wait-for-it.sh

EXPOSE 8787/tcp
EXPOSE 5559/tcp
ENV RSP_LICENSE ""
ENV RSP_TESTUSER rstudio
ENV RSP_TESTUSER_PASSWD rstudio
ENV RSP_TESTUSER_UID 10000
VOLUME ["/etc/rstudio/", "/etc/rstudio-server/license.lic"]

COPY startup.sh /usr/local/bin/startup.sh
RUN chmod +x /usr/local/bin/startup.sh

ENTRYPOINT ["tini", "--"]
CMD ["/usr/local/bin/startup.sh"]
