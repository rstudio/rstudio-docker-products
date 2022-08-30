# News

Please see dedicated image `NEWS.md` files for more details about what has
changed in each image.

This file only captures pervasive, repository-wide changes.

# 2022-08-29
- Added centos7 images to release builds.

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
