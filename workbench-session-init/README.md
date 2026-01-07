# Quick reference

* Maintained by: [the Posit Docker team](https://github.com/rstudio/rstudio-docker-products)
* Where to get help: [our Github Issues page](https://github.com/rstudio/rstudio-docker-products/issues), 
  [the Posit Workbench Documentation](https://docs.posit.co/ide/), 
  [the Posit Community Forum](https://forum.posit.co/c/posit-professional-hosted/posit-workbench/69), 
  or [Posit Support](https://support.posit.co/hc/en-us)
* Posit Workbench image: [Docker Hub](https://hub.docker.com/r/rstudio/rstudio-workbench), 
  [GHCR](https://github.com/rstudio/rstudio-docker-products/pkgs/container/rstudio-workbench)
* Posit Workbench session image: [Docker Hub](https://hub.docker.com/r/rstudio/workbench-session),
  [GHCR](https://github.com/rstudio/rstudio-docker-products/pkgs/container/workbench-session)
* Posit Workbench session init image: [Docker Hub](https://hub.docker.com/r/rstudio/workbench-session-init),
  [GHCR](https://github.com/rstudio/rstudio-docker-products/pkgs/container/workbench-session-init)

# Posit Workbench Session Init Container

This init container can be used to pull the session runtime components into another base session image, which can then 
be used to run Workbench sessions. This image is intended to be used in conjunction with the 
[Posit Workbench Session](https://hub.docker.com/r/rstudio/workbench-session) and 
[Posit Workbench](https://hub.docker.com/r/rstudio/rstudio-workbench) images.

## Supported tags and respective Dockerfile links

* [`jammy-daily`, `ubuntu2204-daily`, `jammy-2026.01.0`, `ubuntu2204-2026.01.0`](https://github.com/rstudio/rstudio-docker-products/blob/main/workbench-session-init/Dockerfile.ubuntu2204)

## License

The license associated with the RStudio Docker Products repository is located [in LICENSE.md](https://github.com/rstudio/rstudio-docker-products/blob/main/LICENSE.md).

As is the case with all container images, the images themselves also contain other software which may be under other
licenses (i.e. bash, linux, system libraries, etc., along with any other direct or indirect dependencies of the primary
software being contained).

It is an image user's responsibility to ensure that use of this image (and any of its dependent layers) complies with
all relevant licenses for the software contained in the image.
