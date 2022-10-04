IMAGE_OS ?= bionic

RSC_VERSION ?= 2022.09.0
RSPM_VERSION ?= 2022.07.2-11
RSW_VERSION ?= 2022.07.2+576.pro12

PREVIEW_TYPE ?= preview
PREVIEW_IMAGE_SUFFIX ?= -preview
PREVIEW_TAG_PREFIX ?=

DRIVERS_VERSION ?= 2021.10.0

R_VERSION ?= 3.6.2  # FIXME(ianpittwood): `R_VERSION` should be the newer version
R_VERSION_ALT ?= 4.1.0

PYTHON_VERSION ?= 3.9.5
PYTHON_VERSION_ALT ?= 3.8.10

RSW_LICENSE ?= ""
RSC_LICENSE ?= ""
RSPM_LICENSE ?= ""

RSW_FLOAT_LICENSE ?= ""
RSC_FLOAT_LICENSE ?= ""
RSPM_FLOAT_LICENSE ?= ""
SSP_FLOAT_LICENSE ?= ""

RSW_LICENSE_SERVER ?= ""
RSC_LICENSE_SERVER ?= ""
RSPM_LICENSE_SERVER ?= ""

# Optional Command for docker run
CMD ?=

SHELL := bash
.ONESHELL:
.SHELLFLAGS := -eu -o pipefail -c
.DELETE_ON_ERROR:
MAKEFLAGS += --warn-undefined-variables
MAKEFLAGS += --no-builtin-rules


# To avoid the issue between mac and linux
# Mac require -i '', while -i is the preferred on linux
UNAME_S := $(shell uname -s)

SED_FLAGS=""
ifeq ($(UNAME_S),Linux)
	SED_FLAGS="-i"
else ifeq ($(UNAME_S),Darwin)
	SED_FLAGS="-i ''"
endif

# Git settings
SHA_SHORT=`git rev-parse --short HEAD`
BRANCH=`git branch --show`

BRANCH_PREFIX ?=
ifeq ($(BRANCH),dev)
	BRANCH_PREFIX ?= dev-
else ifeq ($(BRANCH),dev-rspm)
	BRANCH_PREFIX ?= dev-rspm-
endif

# Docker build kit build settings
BUILDX_PATH ?=
BUILDX_ARGS =
ifneq ($(strip $(BUILDX_PATH)),)
	BUILDX_ARGS = --cache-from=type=local,src=/tmp/.buildx-cache --cache-to=type=local,dest=/tmp/.buildx-cache
endif

# Product-based variable setup for build
PREVIEW_TYPE ?= preview
PRODUCT ?=
ifneq ($(filter $(PRODUCT),workbench r-session-complete workbench-for-microsoft-azure-ml),)
	SHORT_NAME=RSW
	VERSION?=$(RSW_VERSION)
else ifeq ($(PRODUCT),connect)
	SHORT_NAME=RSC
	VERSION?=$(RSC_VERSION)
else ifeq ($(PRODUCT),package-manager)
	SHORT_NAME=RSPM
	VERSION?=$(RSPM_VERSION)
endif
TAG_SAFE_VERSION=`echo "$(VERSION)" | sed -e 's/\+/-/'`

IMAGE_PREFIX=
ifneq ($(PRODUCT),r-session-complete)
	IMAGE_PREFIX=rstudio-
endif

TEST_IMAGE_NAME?=rstudio/$(IMAGE_PREFIX)$(PRODUCT):$(IMAGE_OS)-$(TAG_SAFE_VERSION)

ARCHITECTURE=amd64
ifeq ($(IMAGE_OS),centos7)
	ARCHITECTURE=x86_64
endif
RSW_DOWNLOAD_URL_RELEASE="https://download2.rstudio.org/server/$(IMAGE_OS)/$(ARCHITECTURE)"
RSW_DOWNLOAD_URL_PREVIEW="https://s3.amazonaws.com/rstudio-ide-build/server/$(IMAGE_OS)/$(ARCHITECTURE)"


# Precheck targets
_check-env-on-build:
ifndef PRODUCT
	$(error PRODUCT is undefined)
endif

_check-env-on-lint:
ifndef PRODUCT
	$(error PRODUCT is undefined)
endif
ifndef IMAGE_OS
	$(error IMAGE_OS is undefined)
endif

_check-env-on-test:
ifndef PRODUCT
	$(error PRODUCT is undefined)
endif
ifndef IMAGE_OS
	$(error IMAGE_OS is undefined)
endif


### Release build targets ###
build: _check-env-on-build
	@docker buildx --builder="$(BUILDX_PATH)" build --load $(BUILDX_ARGS) \
		-t rstudio/$(IMAGE_PREFIX)$(PRODUCT):$(IMAGE_OS) \
		-t rstudio/$(IMAGE_PREFIX)$(PRODUCT):$(IMAGE_OS)-$(TAG_SAFE_VERSION) \
		-t rstudio/$(IMAGE_PREFIX)$(PRODUCT):$(IMAGE_OS)-$(TAG_SAFE_VERSION)--$(SHA_SHORT) \
		-t ghcr.io/rstudio/$(IMAGE_PREFIX)$(PRODUCT):$(IMAGE_OS) \
		-t ghcr.io/rstudio/$(IMAGE_PREFIX)$(PRODUCT):$(IMAGE_OS)-$(TAG_SAFE_VERSION) \
		-t ghcr.io/rstudio/$(IMAGE_PREFIX)$(PRODUCT):$(IMAGE_OS)-$(TAG_SAFE_VERSION)--$(SHA_SHORT) \
		--build-arg $(SHORT_NAME)_VERSION="$(VERSION)" \
		--build-arg RSW_DOWNLOAD_URL="$(RSW_DOWNLOAD_URL_RELEASE)" \
		--build-arg R_VERSION=$(R_VERSION) \
		--build-arg R_VERSION_ALT=$(R_VERSION_ALT) \
		--build-arg PYTHON_VERSION=$(PYTHON_VERSION) \
		--build-arg PYTHON_VERSION_ALT=$(PYTHON_VERSION_ALT) \
		--file=./$(PRODUCT)/Dockerfile.$(IMAGE_OS) $(PRODUCT)
	echo rstudio/$(IMAGE_PREFIX)$(PRODUCT):$(IMAGE_OS) \
		rstudio/$(IMAGE_PREFIX)$(PRODUCT):$(IMAGE_OS)-$(TAG_SAFE_VERSION) \
		rstudio/$(IMAGE_PREFIX)$(PRODUCT):$(IMAGE_OS)-$(TAG_SAFE_VERSION)--$(SHA_SHORT) \
		ghcr.io/rstudio/$(IMAGE_PREFIX)$(PRODUCT):$(IMAGE_OS) \
		ghcr.io/rstudio/$(IMAGE_PREFIX)$(PRODUCT):$(IMAGE_OS)-$(TAG_SAFE_VERSION) \
		ghcr.io/rstudio/$(IMAGE_PREFIX)$(PRODUCT):$(IMAGE_OS)-$(TAG_SAFE_VERSION)--$(SHA_SHORT)
build-default:
	$(MAKE) PRODUCT=connect IMAGE_OS=$(IMAGE_OS) build
	$(MAKE) PRODUCT=package-manager IMAGE_OS=$(IMAGE_OS) build
	$(MAKE) PRODUCT=workbench IMAGE_OS=$(IMAGE_OS) build
build-azure:
	$(MAKE) PRODUCT=workbench-for-microsoft-azure-ml IMAGE_OS=$(IMAGE_OS) build
build-all:
	$(MAKE) PRODUCT=connect IMAGE_OS=$(IMAGE_OS) build
	$(MAKE) PRODUCT=package-manager IMAGE_OS=$(IMAGE_OS) build
	$(MAKE) PRODUCT=r-session-complete IMAGE_OS=$(IMAGE_OS) build
	$(MAKE) PRODUCT=workbench IMAGE_OS=$(IMAGE_OS) build
	$(MAKE) PRODUCT=workbench-for-microsoft-azure-ml IMAGE_OS=$(IMAGE_OS) build


### Preview build targets ###
build-preview: _check-env-on-build
	@docker buildx --builder="$(BUILDX_PATH)" build --load $(BUILDX_ARGS) \
        -t rstudio/$(IMAGE_PREFIX)$(PRODUCT)-preview:$(BRANCH_PREFIX)$(IMAGE_OS)-$(TAG_SAFE_VERSION) \
        -t rstudio/$(IMAGE_PREFIX)$(PRODUCT)-preview:$(BRANCH_PREFIX)$(IMAGE_OS)-$(PREVIEW_TYPE) \
        -t ghcr.io/rstudio/$(IMAGE_PREFIX)$(PRODUCT)-preview:$(BRANCH_PREFIX)$(IMAGE_OS)-$(TAG_SAFE_VERSION) \
        -t ghcr.io/rstudio/$(IMAGE_PREFIX)$(PRODUCT)-preview:$(BRANCH_PREFIX)$(IMAGE_OS)-$(PREVIEW_TYPE) \
        --build-arg $(SHORT_NAME)_VERSION=$(VERSION) \
        --build-arg RSW_DOWNLOAD_URL=$(RSW_DOWNLOAD_URL_PREVIEW) \
		--build-arg R_VERSION=$(R_VERSION) \
		--build-arg R_VERSION_ALT=$(R_VERSION_ALT) \
		--build-arg PYTHON_VERSION=$(PYTHON_VERSION) \
		--build-arg PYTHON_VERSION_ALT=$(PYTHON_VERSION_ALT) \
        --file=./$(PRODUCT)/Dockerfile.$(IMAGE_OS) $(PRODUCT)
	echo rstudio/$(IMAGE_PREFIX)$(PRODUCT)-preview:$(BRANCH_PREFIX)$(IMAGE_OS)-$(TAG_SAFE_VERSION) \
		rstudio/$(IMAGE_PREFIX)$(PRODUCT)-preview:$(BRANCH_PREFIX)$(IMAGE_OS)-$(PREVIEW_TYPE) \
		ghcr.io/rstudio/$(IMAGE_PREFIX)$(PRODUCT)-preview:$(BRANCH_PREFIX)$(IMAGE_OS)-$(TAG_SAFE_VERSION) \
		ghcr.io/rstudio/$(IMAGE_PREFIX)$(PRODUCT)-preview:$(BRANCH_PREFIX)$(IMAGE_OS)-$(PREVIEW_TYPE)
build-preview-default:
	$(MAKE) PRODUCT=connect IMAGE_OS=$(IMAGE_OS) build-preview
	$(MAKE) PRODUCT=package-manager IMAGE_OS=$(IMAGE_OS) build-preview
	$(MAKE) PRODUCT=workbench IMAGE_OS=$(IMAGE_OS) build-preview
build-preview-azure:
	$(MAKE) PRODUCT=workbench-for-microsoft-azure-ml IMAGE_OS=$(IMAGE_OS) build-preview
build-preview-all:
	$(MAKE) PRODUCT=connect IMAGE_OS=$(IMAGE_OS) build-preview
	$(MAKE) PRODUCT=package-manager IMAGE_OS=$(IMAGE_OS) build-preview
	$(MAKE) PRODUCT=r-session-complete IMAGE_OS=$(IMAGE_OS) build-preview
	$(MAKE) PRODUCT=workbench IMAGE_OS=$(IMAGE_OS) build-preview
	$(MAKE) PRODUCT=workbench-for-microsoft-azure-ml IMAGE_OS=$(IMAGE_OS) build-preview


### Lint product ###
lint: _check-env-on-lint
	just lint $(PRODUCT) $(IMAGE_OS)
lint-default:
	$(MAKE) PRODUCT=connect IMAGE_OS=$(IMAGE_OS) lint
	$(MAKE) PRODUCT=package-manager IMAGE_OS=$(IMAGE_OS) lint
	$(MAKE) PRODUCT=workbench IMAGE_OS=$(IMAGE_OS) lint
lint-azure:
	$(MAKE) PRODUCT=workbench-for-microsoft-azure-ml IMAGE_OS=$(IMAGE_OS) lint
lint-all:
	$(MAKE) PRODUCT=connect IMAGE_OS=$(IMAGE_OS) lint
	$(MAKE) PRODUCT=package-manager IMAGE_OS=$(IMAGE_OS) lint
	$(MAKE) PRODUCT=r-session-complete IMAGE_OS=$(IMAGE_OS) lint
	$(MAKE) PRODUCT=workbench IMAGE_OS=$(IMAGE_OS) lint
	$(MAKE) PRODUCT=workbench-for-microsoft-azure-ml IMAGE_OS=$(IMAGE_OS) lint


### Test product ###
test: _check-env-on-test
	IMAGE_NAME=$(TEST_IMAGE_NAME) \
	R_VERSION=$(R_VERSION) \
	R_VERSION_ALT=$(R_VERSION_ALT) \
	PYTHON_VERSION=$(PYTHON_VERSION) \
	PYTHON_VERSION_ALT=$(PYTHON_VERSION_ALT) \
	docker-compose -f ./$(PRODUCT)/docker-compose.test.yml run sut
test-i: _check-env-on-test
	IMAGE_NAME=$(TEST_IMAGE_NAME) \
	R_VERSION=$(R_VERSION) \
	R_VERSION_ALT=$(R_VERSION_ALT) \
	PYTHON_VERSION=$(PYTHON_VERSION) \
	PYTHON_VERSION_ALT=$(PYTHON_VERSION_ALT) \
	docker-compose -f ./$(PRODUCT)/docker-compose.test.yml run sut bash
test-default:
	$(MAKE) PRODUCT=connect IMAGE_OS=$(IMAGE_OS) test
	$(MAKE) PRODUCT=package-manager IMAGE_OS=$(IMAGE_OS) test
	$(MAKE) PRODUCT=workbench IMAGE_OS=$(IMAGE_OS) test
test-azure:
	$(MAKE) PRODUCT=workbench-for-microsoft-azure-ml IMAGE_OS=$(IMAGE_OS) test
test-all:
	$(MAKE) PRODUCT=connect IMAGE_OS=$(IMAGE_OS) test
	$(MAKE) PRODUCT=package-manager IMAGE_OS=$(IMAGE_OS) test
	$(MAKE) PRODUCT=r-session-complete IMAGE_OS=$(IMAGE_OS) test
	$(MAKE) PRODUCT=workbench IMAGE_OS=$(IMAGE_OS) test
	$(MAKE) PRODUCT=workbench-for-microsoft-azure-ml IMAGE_OS=$(IMAGE_OS) test


### Update versions shortcuts ###
update-versions:  ## Update the versions for all products
	just \
		RSW_VERSION=$(RSW_VERSION) \
		RSC_VERSION=$(RSC_VERSION) \
		RSPM_VERSION=$(RSPM_VERSION) \
		R_VERSION=$(R_VERSION) \
		R_VERSION_ALT=$(R_VERSION_ALT) \
		PYTHON_VERSION=$(PYTHON_VERSION) \
		PYTHON_VERSION_ALT=$(PYTHON_VERSION_ALT) \
    	DRIVERS_VERSION=$(DRIVERS_VERSION) \
		update-versions


### RStudio Connect ###
run-rsc: run-connect
run-connect:  ## Run RSC container
	docker rm -f rstudio-connect
	docker run -it --privileged \
		--name rstudio-connect \
		-p 3939:3939 \
		-v $(CURDIR)/data/rsc:/var/lib/rstudio-connect \
		-v $(CURDIR)/connect/rstudio-connect.gcfg:/etc/rstudio-connect/rstudio-connect.gcfg \
		-e RSC_LICENSE=$(RSC_LICENSE) \
		rstudio/rstudio-connect:$(IMAGE_OS)-$(RSC_VERSION) $(CMD)


### RStudio Package Manager ###
run-rspm: run-package-manager
run-package-manager:  ## Run RSPM container
	docker rm -f rstudio-package-manager
	docker run -it \
		--name rstudio-package-manager \
		-p 4242:4242 \
		-v $(CURDIR)/data/rspm:/data \
		-v $(CURDIR)/package-manager/rstudio-pm.gcfg:/etc/rstudio-pm/rstudio-pm.gcfg \
		-e RSPM_LICENSE=$(RSPM_LICENSE)  \
		rstudio/rstudio-package-manager:$(RSPM_VERSION) $(CMD)


### r-session-complete ###
run-r-session-complete:  ## Run RSW container
	docker rm -f r-session-complete
	docker run -it \
		--name r-session-complete \
		-p 8788:8788 \
		-v /run \
		-e RSW_LICENSE=$(RSW_LICENSE) \
		rstudio/r-session-complete:$(IMAGE_OS)-$(RSW_TAG_VERSION) $(CMD)


### RStudio Workbench ###
run-rsw: run-workbench
run-workbench: rsw  ## Run RSW container
	docker rm -f rstudio-workbench
	docker run -it \
		--name rstudio-workbench \
		-p 8787:8787 \
		-v $(PWD)/workbench/conf:/etc/rstudio/ \
		-v /run \
		-e RSW_LICENSE=$(RSW_LICENSE) \
		rstudio/rstudio-workbench:$(IMAGE_OS)-$(RSW_TAG_VERSION) $(CMD)


### Floating License Server ###
float:
	docker-compose -f helper/float/docker-compose.yml build
run-float: run-floating-lic-server
run-floating-lic-server:  ## [DO NOT USE IN PRODUCTION] Run the floating license server for pro products
	RSW_FLOAT_LICENSE=$(RSW_FLOAT_LICENSE) RSC_FLOAT_LICENSE=$(RSC_FLOAT_LICENSE) RSPM_FLOAT_LICENSE=$(RSPM_FLOAT_LICENSE) SSP_FLOAT_LICENSE=$(SSP_FLOAT_LICENSE) \
	docker-compose -f helper/float/docker-compose.yml up


### Help menu ###
all: help
help:  ## Show this help menu
	@grep -E '^[0-9a-zA-Z_-]+:.*?##.*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?##"; OFS="\t\t"}; {printf "\033[36m%-30s\033[0m %s\n", $$1, ($$2==""?"":$$2)}'


.PHONY: build \
		test \
		float
