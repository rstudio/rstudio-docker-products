ARG PYTHON_VERSION
ARG R_VERSION
FROM rstudio/content-pro:r${R_VERSION}-py${PYTHON_VERSION}-bionic

MAINTAINER RStudio Docker <docker@rstudio.com>

# Install RStudio Professional Drivers ----------------------------------------#
ARG DRIVERS_VERSION
ARG R_VERSION

RUN apt-get update -y && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y unixodbc unixodbc-dev gdebi-core && \
    rm -rf /var/lib/apt/lists/*

RUN curl -O https://cdn.rstudio.com/drivers/7C152C12/installer/rstudio-drivers_${DRIVERS_VERSION}_amd64.deb && \
    apt-get update && \
    DEBIAN_FRONTEND=noninteractive gdebi --non-interactive rstudio-drivers_${DRIVERS_VERSION}_amd64.deb && \
    rm -rf /var/lib/apt/lists/* && \
    cp /opt/rstudio-drivers/odbcinst.ini.sample /etc/odbcinst.ini
