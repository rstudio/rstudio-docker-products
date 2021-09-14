## Build

By default, the `all` target builds the image.

```console
# Creates rstudio/content-base:r3.6.3-py3.7.6-bionic
make

# Creates rstudio/content-base:r4.0.4-py3.9.2-bionic
make R_VERSION=4.0.4 PYTHON_VERSION=3.9.2
```
