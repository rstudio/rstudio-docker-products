# Base Image

This is a basic image with:

- "most" system dependencies for basic examples
- A single R version
- A single Python version

For now, we are only building `bionic`

## To build

By default, the `all` target builds then pushes the image.

```console
# Creates and pushes both:
# rstudio/content-base:r3.6.3-py3.7.6-bionic
# rstudio/content-base-pro:r3.6.3-py3.7.6-bionic
make

# Creates and pushes both:
# rstudio/content-base:r4.0.4-py3.9.2-bionic
# rstudio/content-base-pro:r4.0.4-py3.9.2-bionic
make R_VERSION=4.0.4 PYTHON_VERSION=3.9.2
```

You can `build` or `build-pro` if you do not want to push (or do not have permissions to
push).  Use `build` to build only the base images, without the pro drivers.
Use `build-pro` to build both the base image and the image with pro drivers.

```console
# Creates only rstudio/content-base:r3.6.3-py3.7.6-bionic
make build

# Creates both:
# rstudio/content-base:r3.6.3-py3.7.6-bionic
# rstudio/content-base-pro:r3.6.3-py3.7.6-bionic
make build-pro

# Creates only rstudio/content-base:r4.0.4-py3.9.2-bionic
make R_VERSION=4.0.4 PYTHON_VERSION=3.9.2 build

# Creates both:
# rstudio/content-base:r4.0.4-py3.9.2-bionic
# rstudio/content-base-pro:r4.0.4-py3.9.2-bionic
make R_VERSION=4.0.4 PYTHON_VERSION=3.9.2 build-pro
```

## Examine images

The `scripts/build-image-yaml.sh` script that runs the
`scripts/examine-image.sh` analysis script within a container. It emits
progress information to stderr and the resulting YAML to stdout.

This command produces the YAML for a single image.

```console
./scripts/build-image-yaml.sh rstudio/content-base:r3.6.3-py3.8.8-bionic > runtime.yaml
```

This command generates a single YAML for all of the available `rstudio/content-base`
and `rstudio/content-base-pro` images:

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
    rstudio/content-base-pro:r3.1.3-py2.7.18-bionic \
    rstudio/content-base-pro:r3.2.5-py2.7.18-bionic \
    rstudio/content-base-pro:r3.3.3-py3.6.13-bionic \
    rstudio/content-base-pro:r3.4.4-py3.6.13-bionic \
    rstudio/content-base-pro:r3.5.3-py3.7.10-bionic \
    rstudio/content-base-pro:r3.6.3-py3.8.8-bionic \
    rstudio/content-base-pro:r4.0.5-py3.8.8-bionic \
    rstudio/content-base-pro:r4.0.5-py3.9.2-bionic \
    rstudio/content-base-pro:r4.1.0-py3.8.8-bionic \
    rstudio/content-base-pro:r4.1.0-py3.9.2-bionic > runtime.yaml
```
