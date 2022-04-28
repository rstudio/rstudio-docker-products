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
        libcap2 \
        libglib2.0-0 \
        libpam-sss \
        libpq5 \
        libsm6 \
        libssl1.0.0 \
        openssl \
        libnss-sss \
        libssl-dev \
        libuser \
        libuser1-dev \
        libxext6 \
        libxrender1 \
        oddjob-mkhomedir \
        openssh-client \
        rrdtool \
        sssd \
        krb5-user \
        sudo \
        supervisor \
        wget \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Add another R version -------------------------------------------------------#

ARG R_VERSION_ALT=4.1.0
RUN apt-get update -qq && \
    curl -O https://cdn.rstudio.com/r/ubuntu-1804/pkgs/r-${R_VERSION_ALT}_1_amd64.deb && \
    DEBIAN_FRONTEND=noninteractive gdebi --non-interactive r-${R_VERSION_ALT}_1_amd64.deb && \
    rm -f ./r-${R_VERSION_ALT}_1_amd64.deb \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*


# Install jupyter -------------------------------------------------------------#

ARG JUPYTER_VERSION=3.8.10
RUN curl -O https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh && \
    bash Miniconda3-latest-Linux-x86_64.sh -bp /opt/python/jupyter && \
    /opt/python/jupyter/bin/conda install -y python==${JUPYTER_VERSION} && \
    rm -rf Miniconda3-latest-Linux-x86_64.sh && \
    /opt/python/jupyter/bin/pip install \
    jupyter==1.0.0 \
    'jupyterlab<3.0.0' \
    rsp_jupyter \
    rsconnect_jupyter && \
    /opt/python/jupyter/bin/jupyter kernelspec remove python3 -f && \
    /opt/python/jupyter/bin/pip uninstall -y ipykernel

# Install RSW/RSC Notebook Extensions --------------------#

RUN /opt/python/jupyter/bin/jupyter-nbextension install --sys-prefix --py rsp_jupyter && \
    /opt/python/jupyter/bin/jupyter-nbextension enable --sys-prefix --py rsp_jupyter && \
    /opt/python/jupyter/bin/jupyter-nbextension install --sys-prefix --py rsconnect_jupyter && \
    /opt/python/jupyter/bin/jupyter-nbextension enable --sys-prefix --py rsconnect_jupyter && \
    /opt/python/jupyter/bin/jupyter-serverextension enable --sys-prefix --py rsconnect_jupyter

# Install Python --------------------------------------------------------------#

ARG PYTHON_VERSION=3.9.5
RUN curl -O https://repo.anaconda.com/miniconda/Miniconda3-4.7.12.1-Linux-x86_64.sh && \
    bash Miniconda3-4.7.12.1-Linux-x86_64.sh -bp /opt/python/${PYTHON_VERSION} && \
    /opt/python/${PYTHON_VERSION}/bin/conda install -y python==${PYTHON_VERSION} && \
    /opt/python/${PYTHON_VERSION}/bin/pip install \
        ipykernel \
        virtualenv \
        && \
    rm -rf Miniconda3-*-Linux-x86_64.sh && \
    /opt/python/${PYTHON_VERSION}/bin/python -m ipykernel install --name py${PYTHON_VERSION} --display-name "Python ${PYTHON_VERSION}"

# Install another Python --------------------------------------------------------------#

ARG PYTHON_VERSION_ALT=3.8.10
RUN curl -O https://repo.anaconda.com/miniconda/Miniconda3-4.7.12.1-Linux-x86_64.sh && \
    bash Miniconda3-4.7.12.1-Linux-x86_64.sh -bp /opt/python/${PYTHON_VERSION_ALT} && \
    /opt/python/${PYTHON_VERSION_ALT}/bin/conda install -y python==${PYTHON_VERSION_ALT} && \
    /opt/python/${PYTHON_VERSION_ALT}/bin/pip install \
        ipykernel \
        virtualenv \
        && \
    rm -rf Miniconda3-*-Linux-x86_64.sh && \
    /opt/python/${PYTHON_VERSION_ALT}/bin/python -m ipykernel install --name py${PYTHON_VERSION_ALT} --display-name "Python ${PYTHON_VERSION_ALT}"

# Runtime settings ------------------------------------------------------------#
RUN curl -L -o /usr/local/bin/wait-for-it.sh https://raw.githubusercontent.com/vishnubob/wait-for-it/master/wait-for-it.sh && \
    chmod +x /usr/local/bin/wait-for-it.sh

# Set default env values
ENV RSW_LICENSE ""
ENV RSW_LICENSE_SERVER ""
ENV RSW_TESTUSER rstudio
ENV RSW_TESTUSER_PASSWD rstudio
ENV RSW_TESTUSER_UID 10000
ENV RSW_LAUNCHER true
ENV RSW_LAUNCHER_TIMEOUT 10
ENV DIAGNOSTIC_DIR /var/log/rstudio
ENV DIAGNOSTIC_ENABLE false
ENV DIAGNOSTIC_ONLY false

# Copy config and startup
COPY startup/* /startup/base/
COPY startup-launcher/* /startup/launcher/
COPY startup-user-provisioning/* /startup/user-provisioning/
COPY supervisord.conf /etc/supervisor/supervisord.conf
COPY --chmod=0775 startup.sh /usr/local/bin/startup.sh

# Install RStudio Workbench --------------------------------------------------#
ARG RSW_VERSION=2022.02.2+485.pro2
ARG RSW_DOWNLOAD_URL=https://download2.rstudio.org/server/bionic/amd64
ARG RSW_NAME=rstudio-workbench
RUN apt-get update --fix-missing \
    && RSW_VERSION_URL=`echo -n "${RSW_VERSION}" | sed 's/+/-/g'` \
    && curl -o rstudio-workbench.deb ${RSW_DOWNLOAD_URL}/${RSW_NAME}-${RSW_VERSION_URL}-amd64.deb \
    && gdebi --non-interactive rstudio-workbench.deb \
    && rm rstudio-workbench.deb \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* \
    && rm -rf /var/lib/rstudio-server/r-versions

# Install VSCode code-server --------------------------------------------------#

RUN rstudio-server install-vs-code /opt/code-server/

# Copy config
COPY conf/* /etc/rstudio/
COPY --chmod=600 sssd.conf /etc/sssd/sssd.conf

# Create log dir
RUN mkdir -p /var/lib/rstudio-server/monitor/log && \
    chown -R rstudio-server:rstudio-server /var/lib/rstudio-server/monitor && \
    mkdir -p /startup/custom/ && \
    echo '\n# allow home directory creation\nsession required pam_mkhomedir.so skel=/etc/skel umask=0022' >> /etc/pam.d/common-session

EXPOSE 8787/tcp
EXPOSE 5559/tcp

ENTRYPOINT []
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/supervisord.conf"]
