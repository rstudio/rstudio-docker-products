ARG BASE_IMAGE
FROM ${BASE_IMAGE}

MAINTAINER RStudio Docker <docker@rstudio.com>

# Install RStudio Professional Drivers ----------------------------------------#
ARG DRIVERS_VERSION
ARG R_VERSION
ARG DEBIAN_FRONTEND=noninteractive

RUN apt-get update -y && \
    apt-get install -y unixodbc unixodbc-dev gdebi-core && \
    rm -rf /var/lib/apt/lists/*

RUN curl -O https://cdn.rstudio.com/drivers/7C152C12/installer/rstudio-drivers_${DRIVERS_VERSION}_amd64.deb && \
    apt-get update && \
    gdebi --non-interactive rstudio-drivers_${DRIVERS_VERSION}_amd64.deb && \
    rm -rf /var/lib/apt/lists/* && \
    cp /opt/rstudio-drivers/odbcinst.ini.sample /etc/odbcinst.ini
