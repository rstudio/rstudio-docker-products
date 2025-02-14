# Posit Workbench Session Init Container

This directory contains a Dockerfile and script that will create an init container to copy session runtime components from a release package into a target mount directory. This init container can be used to pull the session runtime components into another base sesssion image, which can then be used to run Workbench sessions.

## Quick reference

* Maintained by: [the Posit Docker team](https://github.com/rstudio/rstudio-docker-products)
* Where to get help: [our Github Issues page](https://github.com/rstudio/rstudio-docker-products/issues)
* Posit Workbench image: [Docker Hub](https://hub.docker.com/r/rstudio/rstudio-workbench)
* Posit Workbench session image: [Docker Hub](https://hub.docker.com/r/rstudio/workbench-session)
* Posit Workbench session init image: [Docker Hub](https://hub.docker.com/r/rstudio/workbench-session-init)

## Supported tags and respective Dockerfile links

* [`jammy-daily`, `ubuntu2204-daily`, `jammy-2024.12.1`, `ubuntu2204-2024.12.1`](https://github.com/rstudio/rstudio-docker-products/blob/main/workbench-session-init/Dockerfile.2204)

## Building

Just will build an image using a default Connect distribution.

```console
just build
```

Daily builds are also supported. To build the daily image, run:

```console
just preview-bake workbench-session-init-daily
```

## Testing

You can observe what gets copied by the container:

```console
mkdir init
docker run --rm -v $(pwd)/init:/mnt/init rstudio/workbench-session-init:jammy-2024.12.1
# The init directory has been populated with the Workbench session runtime components.
```

You can also test using GOSS:

```console
just test workbench-session-init
```

## Licensing

The license associated with the RStudio Docker Products repository is located [in LICENSE.md](https://github.com/rstudio/rstudio-docker-products/blob/main/LICENSE.md).

As is the case with all container images, the images themselves also contain other software which may be under other
licenses (i.e. bash, linux, system libraries, etc., along with any other direct or indirect dependencies of the primary
software being contained).

It is an image user's responsibility to ensure that use of this image (and any of its dependent layers) complies with
all relevant licenses for the software contained in the image.
