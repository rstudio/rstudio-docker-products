# News

Please see dedicated image `NEWS.md` files for more details about what has
changed in each image.

This file only captures pervasive, repository-wide changes.

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
