#
# Makefile to build the "copy container" Docker images.
#
# Build and push an image with the default configuration.
#     make all
#
# Build and push an image with alternate Connect versions.
#     make RSC_VERSION=<version string>

TAG_BASE?=rstudio/rstudio-connect-content-init-preview
RSC_VERSION?=2022.08.1

all: build
.PHONY: all

# Builds the image using a given RSC distribution for runtime artifacts.
build:
	DOCKER_BUILDKIT=1 docker build --build-arg RSC_VERSION=$(RSC_VERSION) -t $(TAG_BASE):$(RSC_VERSION) -f Dockerfile.bionic .
.PHONY: build

# Do not run push if you are not Cole.
push: build
	docker push $(TAG_BASE):$(RSC_VERSION)
.PHONY: push

test:
	IMAGE_NAME=$(TAG_BASE):$(RSC_VERSION) docker-compose -f docker-compose.test.yml run sut
.PHONY: test
