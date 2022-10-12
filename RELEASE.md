# Release Process

The release process for these docker images is maintained [on Docker
Hub](https://hub.docker.com/u/rstudio) in the RStudio organization.

## Updating Product Versions

To update the version for the `rstudio/rstudio-connect` image, for instance:
- update the `RSC_VERSION` number in the [`Justfile`](./Justfile)
- run `just update-versions`
- submit a PR
- the next build on `main` will tag the image with the appropriate version
  number

For RStudio Connect, edit `RSC_VERSION`.

For RStudio Workbench, edit `RSW_VERSION`.

For RStudio Package Manager, edit `RSPM_VERSION`.

**IMPORTANT NOTE:** The "default" ARG value in the respective `Dockerfile` has
no effect on the build process

## Building Images in CI

GitHub Actions build a matrix of many images:

- on every push to main
- on PRs into main

In addition, for builds that run on main (some are scheduled, there are webhooks, etc.),
we also push to [Docker Hub](https://hub.docker.com/u/rstudio) and [GitHub Container Registry](https://ghcr.io)

## Testing Locally

It is possible to test locally from a product directory by using:

```
just test
```

If you want to write goss tests,
[`dgoss`](https://github.com/aelsabbahy/goss/tree/master/extras/dgoss)
simplifies the process.

- install
  [`dgoss`](https://github.com/aelsabbahy/goss/tree/master/extras/dgoss)
locally
- run the following to create tests interactively:
```
# from ./connect
GOSS_PATH=/path/to/local/goss GOSS_FILES_PATH=./test dgoss edit -it -e RSC_VERSION=1.9.0 rstudio/rstudio-connect

# once in the container
/bin/bash		# shell of preference?
goss validate
goss add --help
```
- to run the test suite as-is
```
# from ./connect
GOSS_PATH=/path/to/local/goss GOSS_FILES_PATH=./test dgoss run -it -e RSC_VERSION=1.9.0 rstudio/rstudio-connect
```
