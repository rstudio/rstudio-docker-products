# Tag from https://hub.docker.com/_/ubuntu/
FROM ubuntu:focal
MAINTAINER RStudio Connect <rsconnect@rstudio.com>
# Install required tools:
# - curl is used to download the runtime tar.gz
RUN export DEBIAN_FRONTEND=noninteractive && \
    apt-get update && \
    apt-get install -y \
    curl \
    && \
    rm -rf /var/lib/apt/lists/*
ARG RSC_VERSION=2022.04.1
RUN mkdir -p /rsc-staging && \
    cd /rsc-staging && \
    RSC_VERSION_URL=`echo -n "${RSC_VERSION}" | sed 's/+/%2B/g'` && \
    curl -fsSL -o rstudio-connect-runtime.tar.gz https://cdn.rstudio.com/connect/$(echo $RSC_VERSION | sed -r 's/([0-9]+\.[0-9]+).*/\1/')/rstudio-connect-runtime-${RSC_VERSION_URL}.tar.gz && \
    mkdir -p /opt/rstudio-connect-runtime && \
    tar -C /opt/rstudio-connect-runtime -xf rstudio-connect-runtime.tar.gz && \
    chmod 755 /opt/rstudio-connect-runtime && \
    cd / && \
    rm -rf /rsc-staging
COPY entrypoint.sh /usr/local/bin/entrypoint.sh
CMD ["/usr/local/bin/entrypoint.sh"]
