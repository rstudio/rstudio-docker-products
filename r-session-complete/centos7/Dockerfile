FROM centos:7

LABEL maintainer="RStudio Docker <docker@rstudio.com>"

# Set versions and platforms
ARG R_VERSION=4.1.0
ARG MINICONDA_VERSION=py37_4.8.3
ARG PYTHON_VERSION=3.9.5
ARG DRIVERS_VERSION=2021.10.0-1

# Install RStudio Workbench session components -------------------------------#

RUN yum update -y && \
    yum install -y \
    libcurl-devel \
    libuser-devel \
    openssl-devel \
    postgresql-libs \
    rrdtool && \
    yum clean all

ARG RSW_VERSION=2022.02.2+485.pro2
ARG RSW_NAME=rstudio-workbench-rhel
ARG RSW_DOWNLOAD_URL=https://s3.amazonaws.com/rstudio-ide-build/server/centos7/x86_64
RUN RSW_VERSION_URL=`echo -n "${RSW_VERSION}" | sed 's/+/-/g'` \
    && curl -o rstudio-workbench.rpm ${RSW_DOWNLOAD_URL}/${RSW_NAME}-${RSW_VERSION_URL}-x86_64.rpm \
    && yum install -y rstudio-workbench.rpm \
    && rm rstudio-workbench.rpm \
    && yum clean all \
    && rm -rf /var/lib/rstudio-server/r-versions

EXPOSE 8788/tcp

# Install additional system packages ------------------------------------------#

RUN yum update -y && \
    yum install -y \
    wget \
    git \
    libxml2-devel \
    subversion \
    which && \
    yum clean all

# Install R -------------------------------------------------------------------#

RUN yum update -y && \
    yum install -y epel-release && \
    yum clean all

RUN curl -O https://cdn.rstudio.com/r/centos-7/pkgs/R-${R_VERSION}-1-1.x86_64.rpm && \
    yum install -y R-${R_VERSION}-1-1.x86_64.rpm && \
    yum clean all && \
    rm -rf R-${R_VERSION}-1-1.x86_64.rpm

RUN ln -s /opt/R/${R_VERSION}/bin/R /usr/local/bin/R && \
    ln -s /opt/R/${R_VERSION}/bin/Rscript /usr/local/bin/Rscript

# Install Python --------------------------------------------------------------#

RUN yum update -y && \
    yum install -y bzip2 && \
    yum clean all

RUN curl -O https://repo.anaconda.com/miniconda/Miniconda3-4.7.12.1-Linux-x86_64.sh && \
    bash Miniconda3-4.7.12.1-Linux-x86_64.sh -bp /opt/python/${PYTHON_VERSION} && \
    /opt/python/${PYTHON_VERSION}/bin/conda install -y python==${PYTHON_VERSION} && \
    rm -rf Miniconda3-*-Linux-x86_64.sh

ENV PATH="/opt/python/${PYTHON_VERSION}/bin:${PATH}"

# Install Jupyter Notebook and RSW/RSC Notebook Extensions and Packages -------#

RUN /opt/python/${PYTHON_VERSION}/bin/pip install \
    jupyter \
    jupyterlab \
    rsp_jupyter \
    rsconnect_jupyter \
    rsconnect_python

RUN /opt/python/${PYTHON_VERSION}/bin/jupyter-nbextension install --sys-prefix --py rsp_jupyter && \
    /opt/python/${PYTHON_VERSION}/bin/jupyter-nbextension enable --sys-prefix --py rsp_jupyter && \
    /opt/python/${PYTHON_VERSION}/bin/jupyter-nbextension install --sys-prefix --py rsconnect_jupyter && \
    /opt/python/${PYTHON_VERSION}/bin/jupyter-nbextension enable --sys-prefix --py rsconnect_jupyter && \
    /opt/python/${PYTHON_VERSION}/bin/jupyter-serverextension enable --sys-prefix --py rsconnect_jupyter

# Install VSCode code-server --------------------------------------------------#

RUN rstudio-server install-vs-code /opt/code-server/

# Install RStudio Professional Drivers ----------------------------------------#

RUN yum update -y && \
    yum install -y unixODBC unixODBC-devel && \
    yum clean all

RUN curl -O https://drivers.rstudio.org/7C152C12/installer/rstudio-drivers-${DRIVERS_VERSION}.el7.x86_64.rpm && \
    yum install -y rstudio-drivers-${DRIVERS_VERSION}.el7.x86_64.rpm && \
    yum clean all && \
    rm -f rstudio-drivers-${DRIVERS_VERSION}.el7.x86_64.rpm && \
    cp /opt/rstudio-drivers/odbcinst.ini.sample /etc/odbcinst.ini

RUN /opt/R/${R_VERSION}/bin/R -e 'install.packages("odbc", repos="https://packagemanager.rstudio.com/cran/__linux__/centos7/latest")'

# Locale configuration --------------------------------------------------------#

RUN localedef -i en_US -f UTF-8 en_US.UTF-8
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8
