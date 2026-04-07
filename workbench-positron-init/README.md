# Quick reference

* Maintained by: [the Posit Docker team](https://github.com/rstudio/rstudio-docker-products)
* Where to get help: [our Github Issues page](https://github.com/rstudio/rstudio-docker-products/issues),
  [the Posit Workbench Documentation](https://docs.posit.co/ide/),
  [the Posit Community Forum](https://forum.posit.co/c/posit-professional-hosted/posit-workbench/69),
  or [Posit Support](https://support.posit.co/hc/en-us)
* Posit Workbench Positron Init image: [Docker Hub](https://hub.docker.com/r/rstudio/workbench-positron-init),
  [GHCR](https://github.com/rstudio/rstudio-docker-products/pkgs/container/workbench-positron-init)

# Posit Workbench Positron Init Container

This init container decouples positron-server from the session-init container, allowing out-of-band Positron
version upgrades in Kubernetes without waiting for a full Workbench release. It copies `bin/positron-server`
to `/mnt/init` based on the `PWB_POSITRON_TARGET` environment variable.

## Supported tags and respective Dockerfile links

* [`jammy-daily`, `ubuntu2204-daily`, `jammy-2026.04.0`, `ubuntu2204-2026.04.0`](https://github.com/rstudio/rstudio-docker-products/blob/main/workbench-positron-init/Dockerfile.ubuntu2204)

## License

The license associated with the RStudio Docker Products repository is located [in LICENSE.md](https://github.com/rstudio/rstudio-docker-products/blob/main/LICENSE.md).

As is the case with all container images, the images themselves also contain other software which may be under other
licenses (i.e. bash, linux, system libraries, etc., along with any other direct or indirect dependencies of the primary
software being contained).

It is an image user's responsibility to ensure that use of this image (and any of its dependent layers) complies with
all relevant licenses for the software contained in the image.
