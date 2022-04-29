FROM ubuntu:bionic
LABEL maintainer="RStudio Docker <docker@rstudio.com>"

# System dependendies and an R installation for package builds -----------------#
ARG R_VERSION=3.6.2
ARG R_DOWNLOAD_URL=https://cdn.rstudio.com/r/ubuntu-1804/pkgs
RUN apt-get update -qq \
    && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
    ca-certificates \
    curl \
    locales \
    && curl -O ${R_DOWNLOAD_URL}/r-${R_VERSION}_1_amd64.deb \
    && DEBIAN_FRONTEND=noninteractive apt-get install -f -y ./r-${R_VERSION}_1_amd64.deb \
    && rm r-${R_VERSION}_1_amd64.deb \
    && rm -rf /var/lib/apt/lists/* \
    && ln -s /opt/R/${R_VERSION}/bin/R /usr/bin/R \
    && ln -s /opt/R/${R_VERSION}/bin/Rscript /usr/bin/Rscript \
    && ln -s /opt/R/${R_VERSION}/lib/R /usr/lib/R

# Locale configuration --------------------------------------------------------#
RUN localedef -i en_US -f UTF-8 en_US.UTF-8
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8
ENV TZ UTC

ENV PATH /opt/rstudio-pm/bin:$PATH

# Runtime settings ------------------------------------------------------------#
ARG TINI_VERSION=0.18.0
RUN curl -L -o /usr/local/bin/tini https://github.com/krallin/tini/releases/download/v${TINI_VERSION}/tini && \
    chmod +x /usr/local/bin/tini

COPY --chmod=0775 startup.sh /usr/local/bin/startup.sh

EXPOSE 4242/tcp
EXPOSE 2112/tcp

# Download RStudio Package Manager ---------------------------------------------#
ARG RSPM_VERSION=2022.04.0-7
ARG RSPM_DOWNLOAD_URL=https://cdn.rstudio.com/package-manager/ubuntu/amd64
RUN apt-get update --fix-missing \
    && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends gdebi-core dpkg-sig \
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

ENV RSPM_LICENSE ""
ENV RSPM_LICENSE_SERVER ""
COPY rstudio-pm.gcfg /etc/rstudio-pm/rstudio-pm.gcfg

# These directories must be owned by rstudio-pm:rstudio-pm for a container to
# work correctly when run as this user. (The container can also be run as root,
# which will have access to these directories anyway.)
RUN mkdir -p /var/run/rstudio-pm /data/launcher_internal \
    && chown rstudio-pm:rstudio-pm /var/run/rstudio-pm \
    && chown -R rstudio-pm:rstudio-pm /data

# Set up licensing to work in userspace mode. This will not prevent activating a
# license as root, but it is required to activate one as the non-root user at
# runtime. It's possible for this to fail and the trail will be considered over,
# in which case we can ignore it anyway.
USER rstudio-pm
RUN license-manager initialize --userspace || true
USER root

ENTRYPOINT ["tini", "--"]
CMD ["/usr/local/bin/startup.sh"]
