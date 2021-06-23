FROM centos:7

LABEL maintainer="RStudio Docker <docker@rstudio.com>"

# Set versions and platforms
ARG R_VERSION=4.0.2
ARG MINICONDA_VERSION=py37_4.8.3
ARG PYTHON_VERSION=3.7.7
ARG DRIVERS_VERSION=1.7.0-1

# Install RStudio Server Pro session components -------------------------------#

RUN yum update -y && \
    yum install -y \
    libcurl-devel \
    libuser-devel \
    openssl-devel \
    postgresql-libs \
    rrdtool && \
    yum clean all

ARG RSP_VERSION=1.4.1717-3
ARG RSP_NAME=rstudio-workbench-rhel
ARG RSP_DOWNLOAD_URL=https://s3.amazonaws.com/rstudio-ide-build/server/centos7/x86_64
RUN curl -O ${RSP_DOWNLOAD_URL}/${RSP_NAME}-${RSP_VERSION}-x86_64.rpm \
    && yum install -y ${RSP_NAME}-${RSP_VERSION}-x86_64.rpm \
    && rm ${RSP_NAME}-${RSP_VERSION}-x86_64.rpm \
    && yum clean all

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

# Install R packages ----------------------------------------------------------#

RUN /opt/R/${R_VERSION}/bin/R -e 'install.packages("devtools", repos="https://packagemanager.rstudio.com/cran/__linux__/centos7/latest")' && \
    /opt/R/${R_VERSION}/bin/R -e 'install.packages("tidyverse", repos="https://packagemanager.rstudio.com/cran/__linux__/centos7/latest")' && \
    /opt/R/${R_VERSION}/bin/R -e 'install.packages("shiny", repos="https://packagemanager.rstudio.com/cran/__linux__/centos7/latest")' && \
    /opt/R/${R_VERSION}/bin/R -e 'install.packages("rmarkdown", repos="https://packagemanager.rstudio.com/cran/__linux__/centos7/latest")' && \
    /opt/R/${R_VERSION}/bin/R -e 'install.packages("plumber", repos="https://packagemanager.rstudio.com/cran/__linux__/centos7/latest")'

# Install Python --------------------------------------------------------------#

RUN yum update -y && \
    yum install -y bzip2 && \
    yum clean all

RUN curl -O https://repo.anaconda.com/miniconda/Miniconda3-${MINICONDA_VERSION}-Linux-x86_64.sh && \
    bash Miniconda3-${MINICONDA_VERSION}-Linux-x86_64.sh -bp /opt/python/${PYTHON_VERSION} && \
    /opt/python/${PYTHON_VERSION}/bin/pip install virtualenv && \
    rm -rf Miniconda3-${MINICONDA_VERSION}-Linux-x86_64.sh

ENV PATH="/opt/python/${PYTHON_VERSION}/bin:${PATH}"

# Install Python packages -----------------------------------------------------#

RUN /opt/python/${PYTHON_VERSION}/bin/pip install \
    altair \
    beautifulsoup4 \
    bokeh \
    cloudpickle \
    cython \
    dash \
    dask \
    flask \
    gensim \
    keras \
    matplotlib \
    nltk \
    numpy \
    pandas \
    pillow \
    plotly \
    pyarrow \
    requests \
    scipy \
    scikit-image \
    scikit-learn \
    scrapy \
    seaborn \
    spacy \
    sqlalchemy \
    statsmodels \
    streamlit \
    tensorflow \
    xgboost

# Install Jupyter Notebook and RSP/RSC Notebook Extensions and Packages -------#

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
    cp /opt/rstudio-drivers/odbcinst.ini.sample /etc/odbcinst.ini

RUN /opt/R/${R_VERSION}/bin/R -e 'install.packages("odbc", repos="https://packagemanager.rstudio.com/cran/__linux__/centos7/latest")'

# Locale configuration --------------------------------------------------------#

RUN localedef -i en_US -f UTF-8 en_US.UTF-8
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8
