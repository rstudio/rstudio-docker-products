# Quick reference

* Maintained by: [the Posit Docker team](https://github.com/rstudio/rstudio-docker-products)
* Where to get help: [our Github Issues page](https://github.com/rstudio/rstudio-docker-products/issues)
* RStudio Workbench image: [Docker Hub](https://hub.docker.com/r/rstudio/rstudio-workbench)
* RStudio r-session-complete image: [Docker Hub](https://hub.docker.com/r/rstudio/r-session-complete)

# Supported tags and respective Dockerfile links

* [`jammy`, `ubuntu2204`, `jammy-2023.09.1`, `ubuntu2204-2023.09.1`](https://github.com/rstudio/rstudio-docker-products/blob/main/r-session-complete/Dockerfile.ubuntu2204)

# What are the r-session-complete images?

Images for R and Python sessions and jobs to be used RStudio Workbench, Launcher, and Kubernetes.

# Notice for support 

1. This image may introduce **BREAKING** changes; as such we recommend:
   - Avoid using the `{operating-system}` tags to avoid unexpected version changes, and
   - Always read through the [NEWS](./NEWS.md) to understand the changes before updating.
1. Outdated images will be removed periodically from DockerHub as product version updates are made. Please make plans to
   update at times or use your own build of the images.
1. These images are meant as a starting point for your needs. Consider creating a fork of this repo, where you can
   continue to merge in changes we make while having your own security scanning, base OS in use, or other custom
   changes. We
   provide [instructions for how to build and use](#how-to-use-these-docker-images)
   for these cases.
1. **Security Note:** These images are provided AS IS based on the build environment at the time their product version was released/updated. They should be reviewed and updated before production use. If your organization has a specific set of security requirements related to CVE/Vulnerability severity levels, you should plan to use the [instructions for building](https://github.com/rstudio/rstudio-docker-products#instructions-for-building) to clone this repository, and rebuild these images to your specific internal security standards.

# How to use these images

The Docker images built from these Dockerfiles are intended to be used for R and
Jupyter sessions and jobs with RStudio Workbench (RSW), Launcher, and
Kubernetes.

Note: These Docker images are not equipped or intended to be used to run RStudio
Workbench within a Docker container. Visit the
[rstudio/rstudio-worbench Docker Hub page](https://hub.docker.com/r/rstudio/rstudio-workbench)
for images built for that purpose.

For more information about RStudio Workbench and Launcher, refer to the
[Launcher Overview](https://solutions.rstudio.com/launcher/overview/) on the
RStudio Solutions website.

For more information about how to use these images with RStudio Workbench and
Launcher, refer to the RStudio support article on [Using Docker images with
RStudio Workbench, Launcher, and
Kubernetes](https://support.rstudio.com/hc/en-us/articles/360019253393-Using-Docker-images-with-RStudio-Server-Pro-Launcher-and-Kubernetes).

We provide simple ways to extend and build the Dockerfiles. After you have cloned the repo, you can create your own 
containers fairly simply with the provided Justfile.

## Overview

Built images are available from the
[rstudio/r-session-complete](https://hub.docker.com/r/rstudio/r-session-complete)
repository on Docker Hub.

These images include the following layers:

* Base OS
* RSW session components
* System packages required for R, R packages, and RStudio Professional Drivers
* One version of R
* One version of Python
* Jupyter Notebooks, JupyterLab, and RSW/RSC notebook extensions
* RStudio Professional Drivers

# Licensing

The license associated with the RStudio Docker Products repository is located [in LICENSE.md](https://github.com/rstudio/rstudio-docker-products/blob/main/LICENSE.md).

As is the case with all container images, the images themselves also contain other software which may be under other
licenses (i.e. bash, linux, system libraries, etc., along with any other direct or indirect dependencies of the primary
software being contained).

It is an image user's responsibility to ensure that use of this image (and any of its dependent layers) complies with
all relevant licenses for the software contained in the image.
