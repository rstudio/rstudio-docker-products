ARG R_VERSION=3.6.2
FROM rstudio/r-base:${R_VERSION}-bionic
LABEL maintainer="RStudio Package Manager Team <rspm@rstudio.com>"

# Locale configuration --------------------------------------------------------#
RUN localedef -i en_US -f UTF-8 en_US.UTF-8
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8
ENV DEBIAN_FRONTEND=noninteractive

ENV PATH /opt/rstudio-pm/bin:$PATH

# Runtime settings ------------------------------------------------------------#
ARG TINI_VERSION=0.18.0
RUN curl -L -o /usr/local/bin/tini https://github.com/krallin/tini/releases/download/v${TINI_VERSION}/tini && \
    chmod +x /usr/local/bin/tini

# Download RStudio Package Manager ---------------------------------------------#
ARG RSPM_VERSION=2022.04.0-7
ARG RSPM_DOWNLOAD_URL=https://cdn.rstudio.com/package-manager/ubuntu/amd64
RUN apt-get update --fix-missing \
    && apt-get install -y --no-install-recommends gdebi-core dpkg-sig \
    && curl -O ${RSPM_DOWNLOAD_URL}/rstudio-pm_${RSPM_VERSION}_amd64.deb \
    && gpg --keyserver keyserver.ubuntu.com --recv-keys 3F32EE77E331692F \
    && dpkg-sig --verify rstudio-pm_${RSPM_VERSION}_amd64.deb \
    && RSTUDIO_INSTALL_NO_LICENSE_INITIALIZATION=1 gdebi -n rstudio-pm_${RSPM_VERSION}_amd64.deb \
    && rm rstudio-pm_${RSPM_VERSION}_amd64.deb \
    && apt-get purge -y gdebi-core dpkg-sig \
    && apt-get autoremove -y \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* \
    && ln -s /opt/rstudio-pm/bin/rspm /usr/local/bin/rspm

# Add run script and set permissions -------------------------------------------#
COPY --chmod=0775 startup.sh /usr/local/bin/startup.sh
RUN mkdir -p /var/run/rstudio-pm \
    && chmod +x /usr/local/bin/startup.sh \
    && chown rstudio-pm:rstudio-pm /usr/local/bin/startup.sh \
    && chown -R rstudio-pm:rstudio-pm /var/run/rstudio-pm

USER rstudio-pm
COPY rstudio-pm.gcfg /etc/rstudio-pm/rstudio-pm.gcfg

# Set up licensing to work in userspace mode. This will not prevent activating a
# license as root, but it is required to activate one as the non-root user at
# runtime. It's possible for this to fail and the trail will be considered over,
# in which case we can ignore it anyway.
RUN license-manager initialize --userspace || true

ENTRYPOINT ["tini", "--"]
CMD ["/usr/local/bin/startup.sh"]
