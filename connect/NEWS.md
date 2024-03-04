# 2024-03-01

- BREAKING: Update Quarto version to 1.4.550

# 2023-08-01
- BREAKING: Removed R 3.6.2, replaced with R 4.1.3.
- Updated R 4.2.0 to 4.2.3.
- Updated Python versions to 3.8.17 and 3.9.17 (latest fix versions).

# 2023-07-25
- Changed `rstudio-connect.gcfg` Python version numbers behavior from statically defined to dynamically filled on build. 

# 2023-07-10

- BREAKING: Deprecate the Ubuntu 18.04 (Bionic Beaver) images.

# 2023-07-07

- WARNING: Refactor image to build _FROM_ the new `product-base` image, this could be potentially breaking for some 
  users.
  - The following packages have been removed from the image: `gdebi-core`, `libsm6`, `libxext6`, and `libxrender1`.
- The [Posit Professional Drivers](https://docs.posit.co/pro-drivers/) are now included by default in the image.

# 2023-04-26

- Add Quarto 1.3.340 to the Ubuntu 18.04 and Ubuntu 22.04 images.
- Enable and configure Connect Quarto support, using the Quarto 1.3.340
  installation.
- Replace Miniconda-based Python installation with Python from https://github.com/rstudio/python-builds in the Ubuntu
  22.04 images. These installations do not contain `virtualenv`.

# 2022-01-23

- Add documentation for license leak bug and possible workarounds/solutions.
- Add an option in the `Justfile` to persist license state files for use
across multiple restarts.

# 2022-12-05

- Add `libnss-sss` and `libpam-sss` to work more nicely with `sssd` as a client
  (if needed)

# 2022-07-11

- Switch container default configuration to use the `Logging` configuration
  section. [See the docs](https://docs.rstudio.com/connect/admin/logging/) for
  more info

# 2022-04-07

- The Dockerfile now uses BuildKit features and must be built with
  DOCKER_BUILDKIT=1.

# 2021.10.0

- Add a bunch of system dependencies. This makes the image build bigger (~4GB),
  but ensures that R and Python content / packages are much more likely to
  build and run without error

# 2021.08.0

- WARNING: this Dockerfile now only works with `YYYY.MM.PATCH` (this is because
  directories used to be structured in three parts like `1.9.0` and are now in
  two like `2021.08`)

# 1.9.0.1

- BREAKING: change how python is installed, some of the PATH definitions, etc.
  - also bump python version from 3.6.5 to 3.8.10 and 3.9.5 (for consistency with other products)
- Add R 4.1.0 to the Connect image

# 1.8.8.2

- Add NEWS.md
