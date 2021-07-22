## content/base

This is a basic image with:

- "most" system dependencies for basic examples
- A single R version
- A single Python version

You must build the content-base image before you can build the content-pro image


## content/pro

This is a basic image with RStudio Pro drivers installed.  These images are built
using the content-base images as the base docker image. Thus, the content-base image
with the corresponding R and Python version must have been built prior to building
these pro images. Attempting to build a pro image using a content-base image that
does not exist will result in an error.


## Examine images

The `scripts/build-image-yaml.sh` script that runs the
`scripts/examine-image.sh` analysis script within a container. It emits
progress information to stderr and the resulting YAML to stdout.

This command produces the YAML for a single image.

```console
./scripts/build-image-yaml.sh rstudio/content-base:r3.6.3-py3.8.8-bionic > runtime.yaml
```

This command generates a single YAML for the available `rstudio/content-base`
and `rstudio/content-pro` images:

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
    rstudio/content-base:r4.1.0-py3.9.2-bionic \
    rstudio/content-pro:r3.1.3-py2.7.18-bionic \
    rstudio/content-pro:r3.2.5-py2.7.18-bionic \
    rstudio/content-pro:r3.3.3-py3.6.13-bionic \
    rstudio/content-pro:r3.4.4-py3.6.13-bionic \
    rstudio/content-pro:r3.5.3-py3.7.10-bionic \
    rstudio/content-pro:r3.6.3-py3.8.8-bionic \
    rstudio/content-pro:r4.0.5-py3.8.8-bionic \
    rstudio/content-pro:r4.0.5-py3.9.2-bionic \
    rstudio/content-pro:r4.1.0-py3.8.8-bionic \
    rstudio/content-pro:r4.1.0-py3.9.2-bionic > runtime.yaml
```

## Build matrix

The json defined in `matrix.json` is loaded by the Github Action to
determine which combinations of R and Python to use when building
our `content-base` and `content-pro` images. To add a new R and Python
version combination, simply update the matrix and the Github Action will publish
the new image combinations to our registries upon the next push to `main`


## Github Actions

Because of the dependency on the content-base images, the github actions that build the pro images
depend on completion of the base image builds in [build-content](../.github/workflows/build-content.yaml)
