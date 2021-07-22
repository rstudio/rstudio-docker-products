# Base Image

This is a basic image with:

- "most" system dependencies for basic examples
- A single R version
- A single Python version

For now, we are only building `bionic`

## To build

By default, the `all` target builds then pushes the image.

```console
# Creates and pushes rstudio/content-base:r3.6.3-py3.7.6-bionic
make

# Creates and pushes rstudio/content-base:r4.0.4-py3.9.2-bionic
make R_VERSION=4.0.4 PYTHON_VERSION=3.9.2
```

You can `build` if you do not want to push (or do not have permissions to
push).

```console
# Creates rstudio/content-base:r3.6.3-py3.7.6-bionic
make build

# Creates rstudio/content-base:r4.0.4-py3.9.2-bionic
make R_VERSION=4.0.4 PYTHON_VERSION=3.9.2 build
```

## Examine images

The `scripts/build-image-yaml.sh` script that runs the
`scripts/examine-image.sh` analysis script within a container. It emits
progress information to stderr and the resulting YAML to stdout.

This command produces the YAML for a single image.

```console
./scripts/build-image-yaml.sh rstudio/content-base:r3.6.3-py3.8.8-bionic > runtime.yaml
```

This command generates a single YAML for the available `rstudio/content-base`
images:

```console
./scripts/build-image-yaml.sh \
    rstudio/content-base:r3.1.3-py2.7.18-bionic \
    rstudio/content-base:r3.2.5-py2.7.18-bionic \
    rstudio/content-base:r3.3.3-py3.6.13-bionic \
    rstudio/content-base:r3.4.4-py3.6.13-bionic \
    rstudio/content-base:r3.5.3-py3.7.10-bionic \
    rstudio/content-base:r3.6.3-py3.8.8-bionic \
    rstudio/content-base:r4.0.5-py3.8.8-bionic \
    rstudio/content-base:r4.0.5-py3.9.2-bionic \
    rstudio/content-base:r4.1.0-py3.8.8-bionic \
    rstudio/content-base:r4.1.0-py3.9.2-bionic > runtime.yaml
```

# Licensing

The license associated with the RStudio Docker Products repository is located [in LICENSE.md](https://github.com/rstudio/rstudio-docker-products/blob/main/LICENSE.md).

As is the case with all container images, the images themselves also contain other software which may be under other
licenses (i.e. bash, linux, system libraries, etc., along with any other direct or indirect dependencies of the primary
software being contained).

It is an image user's responsibility to ensure that use of this image (and any of its dependent layers) complies with
all relevant licenses for the software contained in the image.
