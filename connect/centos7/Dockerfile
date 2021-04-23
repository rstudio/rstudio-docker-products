ARG R_VERSION=3.6.2
FROM rstudio/r-base:${R_VERSION}-centos7
LABEL maintainer="RStudio Docker <docker@rstudio.com>"

# Locale configuration --------------------------------------------------------#
RUN localedef -i en_US -f UTF-8 en_US.UTF-8
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8

# Sys dep installation --------------------------------------------------------#
# install sys deps as defined at https://docs.rstudio.com/rsc/manual-install/
# bzip2 added for miniconda install
RUN yum install -y epel-release
RUN yum install -y bzip2 perl make libpng-devel libsodium-devel tcl tk tk-devel java-1.8.0-openjdk-devel libjpeg-turbo-devel libcurl-devel openssl-devel ImageMagick ImageMagick-c++-devel libxml2-devel cairo-devel git geos-devel unixODBC-devel libicu-devel glpk-devel gmp-devel v8-devel mariadb-devel fontconfig-devel freetype-devel libgit2-devel libssh2-devel zlib-devel gdal-devel gdal proj-devel proj-epsg libtiff-devel fribidi-devel harfbuzz-devel udunits2-devel mesa-libGLU-devel mesa-libGL-devel

# Install Python  -------------------------------------------------------------#
ARG PYTHON_VERSION=3.6.5
RUN curl -o /tmp/miniconda.sh https://repo.anaconda.com/miniconda/Miniconda3-4.5.4-Linux-x86_64.sh && \
    /bin/bash /tmp/miniconda.sh -b -p /opt/python/${PYTHON_VERSION} && \
    rm /tmp/miniconda.sh && \
    /opt/python/${PYTHON_VERSION}/bin/conda clean -tipsy && \
    ln -s /opt/python/${PYTHON_VERSION}/etc/profile.d/conda.sh /etc/profile.d/conda.sh && \
    echo "PATH=/opt/python/${PYTHON_VERSION}/bin:$PATH" > /etc/profile.d/python.sh && \
    /opt/python/${PYTHON_VERSION}/bin/conda clean -a && \
    /opt/python/${PYTHON_VERSION}/bin/pip install 'virtualenv<20' && \
    /opt/python/${PYTHON_VERSION}/bin/pip install --upgrade setuptools
ENV PATH /opt/python/${PYTHON_VERSION}/bin:$PATH

# Runtime settings ------------------------------------------------------------#
ARG TINI_VERSION=0.18.0
RUN curl -L -o /usr/local/bin/tini https://github.com/krallin/tini/releases/download/v${TINI_VERSION}/tini && \
    chmod +x /usr/local/bin/tini

COPY startup.sh /usr/local/bin/startup.sh
RUN chmod +x /usr/local/bin/startup.sh

# Download RStudio Connect -----------------------------------------------------#
ARG RSC_VERSION=1.8.8
RUN curl -L -o rstudio-connect.rpm https://cdn.rstudio.com/connect/$(echo $RSC_VERSION | sed -r 's/([0-9]\.[0-9]\.[0-9]).*/\1/')/rstudio-connect-${RSC_VERSION}.el7.x86_64.rpm \
    && sudo yum -y install rstudio-connect.rpm \
    && rm -rf rstudio-connect.rpm

EXPOSE 3939/tcp
ENV RSC_LICENSE ""
ENV RSC_LICENSE_SERVER ""
COPY rstudio-connect.gcfg /etc/rstudio-connect/rstudio-connect.gcfg
VOLUME ["/data"]

ENTRYPOINT ["tini", "--"]
CMD ["/usr/local/bin/startup.sh"]
