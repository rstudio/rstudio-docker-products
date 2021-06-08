# Base Image

This is a basic image with:

- "most" system dependencies for basic examples
- A single R version
- A single Python version

For now, we are only building `ubuntu18.04`

## To build

By default, the `all` target builds then pushes the image.

```console
# Creates and pushes colearendt/rsc-runtime:r3.6.3-py3.7.6-ubuntu18.04
make

# Creates and pushes colearendt/rsc-runtime:r4.0.4-py3.9.2-ubuntu18.04
make R_VERSION=4.0.4 PYTHON_VERSION=3.9.2
```

You can `build` if you do not want to push (or do not have permissions to
push).

```console
# Creates colearendt/rsc-runtime:r3.6.3-py3.7.6-ubuntu18.04
make build

# Creates colearendt/rsc-runtime:r4.0.4-py3.9.2-ubuntu18.04
make R_VERSION=4.0.4 PYTHON_VERSION=3.9.2 build
```
