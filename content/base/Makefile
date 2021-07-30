#
# Makefile to build the "base" Docker images.
#
# Build and push an image with the default configuration.
#     make all
#
# Build and push an image with alternate R/Python versions.
#     make R_VERSION=4.0.4 PYTHON_VERSION=3.9.2
#
# Print the Docker tag associated with the image:
#     make tag
#     make R_VERSION=4.0.4 PYTHON_VERSION=3.9.2 tag

DISTRIBUTION=bionic
TAG_BASE=rstudio/content-base
R_VERSION=3.6.3
PYTHON_VERSION=3.7.6

all: build
.PHONY: all

# Builds the image for a single distribution. Expects that the Dockerfile for
# this image is in a sub-directory with the distribution name as its name.
#
# We could, in the future, follow the lead of r-builds and use docker-compose
# and perform the build in parallel.
# See: https://github.com/rstudio/r-builds/blob/0eaf4ff908f5944c152f89128bbffb3f73ce1c95/Makefile#L7-L8
build:
	docker build --build-arg R_VERSION=$(R_VERSION) --build-arg PYTHON_VERSION=$(PYTHON_VERSION) -t $(TAG_BASE):r$(R_VERSION)-py$(PYTHON_VERSION)-$(DISTRIBUTION) $(DISTRIBUTION)
.PHONY: build

push: build
	docker push $(TAG_BASE):r$(R_VERSION)-py$(PYTHON_VERSION)-$(DISTRIBUTION)
.PHONY: push

# Enumeration of image tags for all supported distributions.
TAGS=$(DISTRIBUTIONS:%=$(TAG_BASE):r$(R_VERSION)-py$(PYTHON_VERSION)-%)

# Prints the Docker tag associated with the configured image.
tag:
	@echo "$(TAG_BASE):r$(R_VERSION)-py$(PYTHON_VERSION)-$(DISTRIBUTION)"
.PHONY: tag
