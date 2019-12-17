# Release Process

The release process for these docker images is maintained [on Docker
Hub](https://hub.docker.com/u/rstudio) in the RStudio organization.

## Updating Product Versions

Each product has a `*_VERSION` file in its folder. This file is used to specify
the version number for building / tagging images.

To update the version for the `rstudio/rstudio-server-pro` image, for instance:
- update the version number in
  [`server-pro/RSP_VERSION`](./server-pro/RSP_VERSION)
- submit a PR
- the next build on `master` will tag the image with the appropriate version
  number

For RStudio Connect, edit [`connect/RSC_VERSION`](./connect/RSC_VERSION)

For RStudio Package Manager, edit
[`package-manager/RSPM_VERSION`](./package-manager/RSPM_VERSION)

**IMPORTANT NOTE:** The "default" ARG value in the respective `Dockerfile` has
no effect on the build process

## Building Images on Docker Hub

Images are built automatically from the `master` branch [on Docker
Hub](https://hub.docker.com/u/rstudio).

These builds are [configured in the Docker Hub
UI](https://docs.docker.com/docker-hub/builds/).

On new commits to master:
- Builds are initiated for `rstudio/rstudio-server-pro`,
  `rstudio/rstudio-package-manager`, and `rstudio/rstudio-connect` images
- These builds get the tag `latest`
- `hooks/build` ensures that the appropriate `RSP_VERSION`, `RSPM_VERSION` or
  `RSC_VERSION` gets used by the build
- `hooks/post_push` tags the `latest` build with the appropriate version as
  well

More advanced build specifications are [articulated
here](https://docs.docker.com/docker-hub/builds/advanced/).

We also want to thank [this
article](https://windsock.io/automated-docker-image-builds-with-multiple-tags/)
for the inspiration behind our tagging process.
