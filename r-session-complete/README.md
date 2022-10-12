# r-session-complete

Dockerfiles for R and Python sessions and jobs to be used RStudio Workbench,
Launcher, and Kubernetes.

**IMPORTANT:** There are a few things you need to know before using these images:

1. These images are provided as a convenience to RStudio customers and are not formally supported by RStudio. If you
   have questions about these images, you can ask them in the issues in the repository or to your support
   representative, who will route them appropriately.
2. Outdated images will be removed periodically from DockerHub as product version updates are made. Please make plans to
   update at times or use your own build of the images.
3. These images are meant as a starting point for your needs. Consider creating a fork of this repo, where you can
   continue to merge in changes we make while having your own security scanning, base OS in use, or other custom
   changes. We
   provide [instructions for how to build and use](#how-to-use-these-docker-images)
   for these cases.

## How to Use These Docker Images

The Docker images built from these Dockerfiles are intended to be used for R and
Jupyter sessions and jobs with RStudio Workbench (RSW), Launcher, and
Kubernetes.

Note: These Docker images are not equipped or intended to be used to run RStudio
Workbench within a Docker container. Visit the
[rstudio/rstudio-docker-products](https://github.com/rstudio/rstudio-docker-products)
repository for images built for that purpose.

For more information about RStudio Workbench and Launcher, refer to the
[Launcher Overview](https://solutions.rstudio.com/launcher/overview/) on the
RStudio Solutions website.

For more information about how to use these images with RStudio Workbench and
Launcher, refer to the RStudio support article on [Using Docker images with
RStudio Workbench, Launcher, and
Kubernetes](https://support.rstudio.com/hc/en-us/articles/360019253393-Using-Docker-images-with-RStudio-Server-Pro-Launcher-and-Kubernetes).

We provide simple ways to extend and build the Dockerfiles. After you have cloned the repo, you can create your own containers fairly simply with the provided Justfile.

## Docker Images on Docker Hub

Built images are available from the
[rstudio/r-session-complete](https://hub.docker.com/r/rstudio/r-session-complete)
repository on Docker Hub.

## Docker Image Layers

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
