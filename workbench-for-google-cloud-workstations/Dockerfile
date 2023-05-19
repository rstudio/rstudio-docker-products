FROM us-central1-docker.pkg.dev/cloud-workstations-images/predefined/base:latest

### ARG declarations ###
ARG DEBIAN_FRONTEND=noninteractive
ARG R_VERSION=4.2.3
ARG R_VERSION_ALT=4.1.3
ARG PYTHON_VERSION=3.10.11
ARG PYTHON_VERSION_ALT=3.9.16
ARG PYTHON_VERSION_JUPYTER=3.10.11
ARG QUARTO_VERSION=1.3.324
ARG DRIVERS_VERSION=2022.11.0
ARG RSW_VERSION=2023.03.1+446.pro1
ARG RSW_NAME=rstudio-workbench
ARG RSW_DOWNLOAD_URL=https://download2.rstudio.org/server/bionic/amd64

ENV RSW_LICENSE ""
ENV RSW_LICENSE_SERVER ""
ENV RSW_TESTUSER user
ENV RSW_TESTUSER_PASSWD rstudio
ENV RSW_TESTUSER_UID 10000
ENV RSW_LAUNCHER true
ENV RSW_LAUNCHER_TIMEOUT 10
ENV DIAGNOSTIC_DIR /var/log/rstudio
ENV DIAGNOSTIC_ENABLE false
ENV DIAGNOSTIC_ONLY false
ENV LICENSE_MANAGER_PATH /usr/lib/rstudio-server/bin

ENV WORKBENCH_JUPYTER_PATH=/usr/local/bin/jupyter

### Update/upgrade system packages ###
RUN apt-get update --fix-missing  \
    && apt-get upgrade -yq \
    && apt-get install -yq --no-install-recommends \
      apt-transport-https \
      build-essential \
      ca-certificates \
      default-jdk \
      dirmngr \
      dpkg-sig \
      gnupg \
      krb5-user \
      libcap2 \
      libcurl4-gnutls-dev \
      libglib2.0-0 \
      libicu-dev \
      libnss-sss \
      libpam-sss \
      libpq-dev \
      libpq5 \
      libsecret-1-dev \
      libsm6 \
      libssl-dev \
      libuser \
      libuser1-dev \
      libxext6 \
      libxrender1 \
      locales \
      oddjob-mkhomedir \
      rrdtool \
      sssd \
      supervisor \
      tcl \
      tk \
      tk-dev \
      tk-table \
    && rm -rf /var/lib/apt/lists/*

### Install R versions ###
RUN curl -O https://cdn.rstudio.com/r/ubuntu-2004/pkgs/r-${R_VERSION}_1_amd64.deb \
    && curl -O https://cdn.rstudio.com/r/ubuntu-2004/pkgs/r-${R_VERSION_ALT}_1_amd64.deb \
    && apt-get update \
    && apt-get install -yq --no-install-recommends ./r-${R_VERSION}_1_amd64.deb \
    && apt-get install -yq --no-install-recommends ./r-${R_VERSION_ALT}_1_amd64.deb \
    && rm -f ./r-${R_VERSION}_1_amd64.deb \
    && rm -f ./r-${R_VERSION_ALT}_1_amd64.deb \
    && ln -s /opt/R/${R_VERSION}/bin/R /usr/local/bin/R \
    && ln -s /opt/R/${R_VERSION}/bin/Rscript /usr/local/bin/Rscript

### Install Python versions ###
RUN curl -O https://cdn.rstudio.com/python/ubuntu-2004/pkgs/python-${PYTHON_VERSION}_1_amd64.deb \
    && curl -O https://cdn.rstudio.com/python/ubuntu-2004/pkgs/python-${PYTHON_VERSION_ALT}_1_amd64.deb \
    && apt-get update \
    && apt-get install -yq --no-install-recommends ./python-${PYTHON_VERSION}_1_amd64.deb \
    && apt-get install -yq --no-install-recommends ./python-${PYTHON_VERSION_ALT}_1_amd64.deb \
    && rm -rf python-${PYTHON_VERSION}_1_amd64.deb \
    && rm -rf python-${PYTHON_VERSION_ALT}_1_amd64.deb \
    && /opt/python/${PYTHON_VERSION}/bin/python3 -m pip install 'virtualenv<20' \
    && /opt/python/${PYTHON_VERSION}/bin/python3 -m pip install --upgrade setuptools \
    && /opt/python/${PYTHON_VERSION}/bin/python3 -m pip install --upgrade pip \
    && /opt/python/${PYTHON_VERSION_ALT}/bin/python3 -m pip install 'virtualenv<20' \
    && /opt/python/${PYTHON_VERSION_ALT}/bin/python3 -m pip install --upgrade setuptools \
    && /opt/python/${PYTHON_VERSION_ALT}/bin/python3 -m pip install --upgrade pip

### Install basic data science packages for Python and R ###
COPY deps/* /
RUN /opt/python/${PYTHON_VERSION}/bin/python3 -m pip install -r /py_packages.txt \
    && /opt/python/${PYTHON_VERSION_ALT}/bin/python3 -m pip install -r /py_packages.txt \
    && ./install_r_packages.sh \
    && rm install_r_packages.sh py_packages.txt r_packages.txt

### Locale configuration ###
RUN localedef -i en_US -f UTF-8 en_US.UTF-8
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8

### Install Quarto ###
RUN curl -o quarto-linux-amd64.deb -L https://github.com/quarto-dev/quarto-cli/releases/download/v${QUARTO_VERSION}/quarto-${QUARTO_VERSION}-linux-amd64.deb \
    && apt-get install -yq ./quarto-linux-amd64.deb \
    && rm quarto-linux-amd64.deb


### Install Pro Drivers ###
RUN apt-get update \
    && apt-get install -yq --no-install-recommends unixodbc unixodbc-dev \
    && curl -O https://cdn.rstudio.com/drivers/7C152C12/installer/rstudio-drivers_${DRIVERS_VERSION}_amd64.deb \
    && apt-get update \
    && apt-get install -yq --no-install-recommends ./rstudio-drivers_${DRIVERS_VERSION}_amd64.deb \
    && rm -f ./rstudio-drivers_${DRIVERS_VERSION}_amd64.deb \
    && rm -rf /var/lib/apt/lists/* \
    && cp /opt/rstudio-drivers/odbcinst.ini.sample /etc/odbcinst.ini \
    && /opt/R/${R_VERSION}/bin/R -e 'install.packages("odbc", repos="https://packagemanager.rstudio.com/cran/__linux__/focal/latest")'

### Install Workbench ###
SHELL ["/bin/bash", "-o", "pipefail", "-c"]
RUN curl -o rstudio-workbench.deb "${RSW_DOWNLOAD_URL}/${RSW_NAME}-${RSW_VERSION//+/-}-amd64.deb" \
    && gpg --keyserver keyserver.ubuntu.com --recv-keys 3F32EE77E331692F \
    && dpkg-sig --verify ./rstudio-workbench.deb \
    && apt-get update \
    && apt-get install -y --no-install-recommends ./rstudio-workbench.deb \
    && rm ./rstudio-workbench.deb \
    && apt-get autoremove -y \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* \
    && rm -rf /var/lib/rstudio-server/r-versions

COPY --chmod=0775 startup.sh /usr/local/bin/startup.sh
COPY startup-launcher/* /startup/launcher/
COPY startup-user-provisioning/* /startup/user-provisioning/
COPY startup/* /startup/base/
COPY supervisord.conf /etc/supervisor/supervisord.conf

### Install Jupyter and extensions ###
RUN /opt/python/"${PYTHON_VERSION_JUPYTER}"/bin/python -m venv /opt/python/jupyter \
    && /opt/python/jupyter/bin/pip install \
      jupyter \
      jupyterlab \
      rsconnect_jupyter \
      rsconnect_python \
      rsp_jupyter \
      workbench_jupyterlab \
    && ln -s /opt/python/jupyter/bin/jupyter /usr/local/bin/jupyter \
    && /opt/python/jupyter/bin/jupyter-nbextension install --sys-prefix --py rsp_jupyter \
    && /opt/python/jupyter/bin/jupyter-nbextension enable --sys-prefix --py rsp_jupyter \
    && /opt/python/jupyter/bin/jupyter-nbextension install --sys-prefix --py rsconnect_jupyter \
    && /opt/python/jupyter/bin/jupyter-nbextension enable --sys-prefix --py rsconnect_jupyter \
    && /opt/python/jupyter/bin/jupyter-serverextension enable --sys-prefix --py rsconnect_jupyter \
    && /opt/python/jupyter/bin/python -m ipykernel install --name py${PYTHON_VERSION} --display-name "Python ${PYTHON_VERSION}" \
    && /opt/python/jupyter/bin/python -m ipykernel install --name py${PYTHON_VERSION_ALT} --display-name "Python ${PYTHON_VERSION_ALT}"

RUN curl -L -o /usr/local/bin/wait-for-it.sh https://raw.githubusercontent.com/rstudio/wait-for-it/master/wait-for-it.sh \
    && chmod +x /usr/local/bin/wait-for-it.sh

COPY --chmod=600 sssd.conf /etc/sssd/sssd.conf
COPY conf/* /etc/rstudio/
COPY --chmod=600 conf/launcher.p* /etc/rstudio

RUN mkdir -p /var/lib/rstudio-server/monitor/log \
    && chown -R rstudio-server:rstudio-server /var/lib/rstudio-server/monitor \
    && mkdir -p /startup/custom/ \
    && printf '\n# allow home directory creation\nsession required pam_mkhomedir.so skel=/etc/skel umask=0022' >> /etc/pam.d/common-session

COPY --chmod=755 workstation-startup/* /etc/workstation-startup.d/
COPY --chmod=644 jupyter/jupyter_notebook_config.json /opt/python/jupyter/etc/jupyter/jupyter_notebook_config.json

### Clean up ###
RUN apt-get remove -yq dpkg-sig \
    && apt-get install -yqf --no-install-recommends \
    && apt-get autoremove -yq \
    && apt-get clean -yq \
    && rm -rf /var/lib/apt/lists/*

EXPOSE 80/tcp
EXPOSE 5559/tcp
