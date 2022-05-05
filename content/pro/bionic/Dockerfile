ARG BASE_IMAGE
FROM ${BASE_IMAGE}

MAINTAINER RStudio Docker <docker@rstudio.com>

# Install RStudio Professional Drivers ----------------------------------------#
ARG DRIVERS_VERSION
ARG R_VERSION

RUN apt-get update -y && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y unixodbc unixodbc-dev gdebi-core && \
    rm -rf /var/lib/apt/lists/*

RUN curl -O https://drivers.rstudio.org/7C152C12/installer/rstudio-drivers_${DRIVERS_VERSION}_amd64.deb && \
    apt-get update && \
    DEBIAN_FRONTEND=noninteractive gdebi --non-interactive rstudio-drivers_${DRIVERS_VERSION}_amd64.deb && \
    rm -rf /var/lib/apt/lists/* && \
    cp /opt/rstudio-drivers/odbcinst.ini.sample /etc/odbcinst.ini

COPY maybe_install_quarto.sh /tmp/maybe_install_quarto.sh
RUN /opt/R/${R_VERSION}/bin/R -e 'install.packages("odbc", repos="https://packagemanager.rstudio.com/cran/__linux__/bionic/latest")' && \
    /tmp/maybe_install_quarto.sh && \
    rm -f /tmp/maybe_install_quarto.sh
