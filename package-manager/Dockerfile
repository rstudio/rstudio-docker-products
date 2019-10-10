ARG R_VERSION=3.6
FROM rstudio/r-base:${R_VERSION}-centos7
LABEL maintainer="sol-eng@rstudio.com"

# Locale configuration --------------------------------------------------------#
RUN localedef -i en_US -f UTF-8 en_US.UTF-8
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8

# Install RStudio Package Manager ---------------------------------------------#
ARG RSPM_VERSION=1.0.14-7
RUN curl -O https://s3.amazonaws.com/rstudio-package-manager/centos/x86_64/rstudio-pm-${RSPM_VERSION}.x86_64.rpm && \
    yum install -y --nogpgcheck rstudio-pm-${RSPM_VERSION}.x86_64.rpm && \
    rm rstudio-pm-${RSPM_VERSION}.x86_64.rpm
RUN mkdir -p /var/run/rstudio-pm
ENV PATH /opt/rstudio-pm/bin:$PATH

# Runtime settings ------------------------------------------------------------#
ARG TINI_VERSION=0.18.0
RUN curl -L -o /usr/local/bin/tini https://github.com/krallin/tini/releases/download/v${TINI_VERSION}/tini && \
    chmod +x /usr/local/bin/tini

COPY startup.sh /usr/local/bin/startup.sh
RUN chmod +x /usr/local/bin/startup.sh

EXPOSE 4242/tcp
ENV RSPM_LICENSE ""
COPY rstudio-pm.gcfg /etc/rstudio-pm/rstudio-pm.gcfg
VOLUME ["/data", "/etc/rstudio-pm/license.lic"]

ENTRYPOINT ["tini", "--"]
CMD ["/usr/local/bin/startup.sh"]
