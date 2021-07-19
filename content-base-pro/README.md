# Pro Base Image

This is a basic image with RStudio Pro drivers installed.  These images are built
using the content-base images as the base docker image. Thus, the content-base image
with the corresponding R and Python version must have been built prior to building
these pro images. Attempting to build a pro image using a content-base image that
does not exist will result in an error.

The make targets for building these pro images are the same as the the targets for the base images.


## Github Actions

Because of the dependency on the content-base images, the github action that builds these images
depends on completion of the [build-content-base](../.github/workflows/build-content-base.yaml) action
