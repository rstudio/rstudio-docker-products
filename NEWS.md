# News

Please see dedicated image `NEWS.md` files for more details about what has
changed in each image.

This file only captures pervasive, repository-wide changes.

# 2024-04-10

- Change build orchestration to use `docker buildx bake` for all images.

# 2024-03-14

- Update Professional Drivers to 2024.03.0

# 2024-02-01

- Update Pro Drivers to 2023.12.1

# 2023-08-07

- Removed base image Ubuntu 18.04 builds.

# 2023-08-01
- Overhauled the workflows for this repository to use official Github Actions over `just` targets for building, testing,
scanning, and pushing images.
- Added updated Python versions to 3.9.17 and 3.8.17 for Ubuntu base images and 3.9.14 and 3.8.15 for CentOS 
base images (not yet in use).
- Added updated R versions to 4.2.3 and 4.1.3 for base images (not yet in use).
- Added scheduled builds for latest release images to keep images up to date with security patches. 

# 2022-11-10
- We replaced Ubuntu codenames with explicit version numbers for ease of use. Images will still be tagged with *both*
the OS version number and the codename to retain backwards compatibility.

# 2022-11-07
- Potentially breaking changes around tagging with workbench due to simplifying the tagging approach.
- Remove internal version strings e.g. `554.pro3`.

# 2022-10-12
- We replaced all `make` definitions with [`just`](https://just.systems/man/en) for ease of use.

# 2022-08-24
- We removed the generic latest tag from all products (excluding content images).
  Now `latest` variants of images are os-specific. When pulling the latest version of
  a product replace the latest tag with the desired os. I.E. `rstudio/rstudio-connect:latest` is
  now `rstudio/rstudio-connect:bionic`.

# 2022-08-01

- We flatted the folder structure for more consistency and better organization
  of various operating systems. For instance, instead of occasional
  subdirectories for OS (i.e. `bionic` or `centos7`), we now have
  `Dockerfile.bionic` and `Dockerfile.centos7`.  Apologies in advance for any
  merge conflicts this might cause!

# 2022-07

- All containers, with the exception of RStudio Connect, may now be run as unprivileged. Please see
  [RStudio Professional Product Root & Privileged Requirements](https://support.rstudio.com/hc/en-us/articles/1500005369282)
  for additional information.

# 2021-10

- *BREAKING*: Rstudio Server Pro has Been Renamed to `Rstudio Workbench`
  - Important environment variables have been renamed from `RSP_` prefix to
    `RSW_` prefix
  - *Make Commands*, *`server-pro` directory*, *docker-compose.yaml* and any
    *RSP* prefixes have also been rebranded.

# 2021-06-30

- Switch Docker Hub builds to GitHub Actions
