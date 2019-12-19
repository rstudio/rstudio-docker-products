# Release Process

The release process for these docker images is maintained [on Docker
Hub](https://hub.docker.com/u/rstudio) in the RStudio organization.

## Updating Product Versions

Each product has a
[`.env`](https://docs.docker.com/compose/environment-variables/) file in its
folder. This file is used to specify the version number for building / tagging
images.

To update the version for the `rstudio/rstudio-server-pro` image, for instance:
- update the `RSP_VERSION` number in the [`Makefile`](./Makefile)
- run `make update-versions`
- submit a PR
- the next build on `master` will tag the image with the appropriate version
  number

For RStudio Connect, edit `RSC_VERSION`

For RStudio Package Manager, edit `RSPM_VERSION`

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

## Testing PRs on Docker Hub

All PRs go through the `Autotest` setup [on Docker
Hub](https://docs.docker.com/docker-hub/builds/automated-testing/).

- Each folder has a `docker-compose.test.yml` file that orchestrates the test
- The `test/run_tests.sh` script is mounted into the container and run
    - This script downloads and installs `goss`
- `test/goss.yaml` is mounted into the container to actually run the tests

Read more about [goss](https://goss.rocks) [in the
manual](https://github.com/aelsabbahy/goss/blob/master/docs/manual.md).

## Testing Locally

It is possible to test locally from a product directory by using:

```
# from ./server-pro
docker-compose -f docker-compose.test.yml up
```

If you want to write goss tests,
[`dgoss`](https://github.com/aelsabbahy/goss/tree/master/extras/dgoss)
simplifies the process.

- install
  [`dgoss`](https://github.com/aelsabbahy/goss/tree/master/extras/dgoss)
locally
- run the following to create tests interactively:
```
# from ./server-pro
GOSS_PATH=/path/to/local/goss GOSS_FILES_PATH=./test dgoss edit -it -e RSP_VERSION=1.2.5001-3 rstudio/sol-eng-rstudio:1.2.5001-3

# once in the container
/bin/bash		# shell of preference?
goss validate
goss add --help
```
- to run the test suite as-is
```
# from ./server-pro
GOSS_PATH=/path/to/local/goss GOSS_FILES_PATH=./test dgoss run -it -e RSP_VERSION=1.2.5001-3 rstudio/sol-eng-rstudio:1.2.5001-3
```
