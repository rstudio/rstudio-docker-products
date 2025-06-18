# Quick reference

* Maintained by: [the Posit Docker team](https://github.com/rstudio/rstudio-docker-products)
* Where to get help: [our Github Issues page](https://github.com/rstudio/rstudio-docker-products/issues), [the Posit Connect Documentation](https://docs.posit.co/connect/), 
  [the Posit Community Forum](https://forum.posit.co/c/posit-professional-hosted/posit-connect/27), or [Posit Support](https://support.posit.co/hc/en-us)
* Posit Connect image: [Docker Hub](https://hub.docker.com/r/rstudio/rstudio-connect), [GHCR](https://github.com/rstudio/rstudio-docker-products/pkgs/container/rstudio-connect)
* Posit Connect Content Init image: [Docker Hub](https://hub.docker.com/r/rstudio/rstudio-connect-content-init), [GHCR](https://github.com/rstudio/rstudio-docker-products/pkgs/container/rstudio-connect-content-init)

# Supported tags and respective Dockerfile links

* [`jammy`, `ubuntu2204`, `jammy-2025.06.0`, `ubuntu2204-2025.06.0`](https://github.com/rstudio/rstudio-docker-products/blob/main/connect/Dockerfile.2204)

# RStudio Connect Content Init Container

This container is intended for use as an "init container" to pull
runtime components into another container, which can then be used with Connect and
Launcher to build/run content. This container [can be extended to include additional
content](https://docs.posit.co/helm/examples/connect/container-images/custom-images.html)
beyond what is provided by default.

This image is primarily used in Kubernetes deployments and is leveraged by the Posit 
Connect Helm chart. Additional information about the Helm chart can be found in the
[Posit Connect Helm Chart documentation](https://docs.posit.co/helm/charts/rstudio-connect/README.html).

# License

The license associated with the RStudio Docker Products repository is located [in LICENSE.md](https://github.com/rstudio/rstudio-docker-products/blob/main/LICENSE.md).

As is the case with all container images, the images themselves also contain other software which may be under other
licenses (i.e. bash, linux, system libraries, etc., along with any other direct or indirect dependencies of the primary
software being contained).

It is an image user's responsibility to ensure that use of this image (and any of its dependent layers) complies with
all relevant licenses for the software contained in the image.
