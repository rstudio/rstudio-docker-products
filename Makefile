IMAGE_OS ?= bionic

RSC_VERSION ?= 2022.08.1
RSPM_VERSION ?= 2022.07.2-11
RSW_VERSION ?= 2022.07.2+576.pro12
RSW_TAG_VERSION=`echo "$(RSW_VERSION)" | sed -e 's/\+/-/'`

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

SHA_SHORT=`git rev-parse --short HEAD`

# Docker build settings
BUILDX_PATH ?=
BUILDX_ARGS =
ifneq ($(strip $(BUILDX_PATH)),)
	BUILDX_ARGS = --cache-from=type=local,src=/tmp/.buildx-cache --cache-to=type=local,dest=/tmp/.buildx-cache
endif


### Generics/Defaults ###
all: help

images: build
build: rsc rspm rsw  ## Build primary images
build-azure: rsw-azure  ## Build Azure images
build-all: rsc rspm rsw r-session-complete rsw-azure  ## Build all images

lint: lint-rsc lint-rspm lint-rsw  ## Lint primary images
lint-azure: lint-rsw-azure  ## Lint Azure images
lint-all: lint-rsc lint-rspm lint-rsw lint-r-session-complete lint-rsw-azure  ## Lint all images

test: test-rsc test-rspm test-rsw
test-azure: test-rsw-azure
test-all: test-rsc test-rspm test-rsw test-r-session-complete test-rsw-azure


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
rsc: connect
connect:  ## Build RSC image
	docker buildx --builder="$(BUILDX_PATH)" build \
		--load $(BUILDX_ARGS) \
		--build-arg R_VERSION=$(R_VERSION) \
		--build-arg R_VERSION_ALT=$(R_VERSION_ALT) \
		--build-arg PYTHON_VERSION=$(PYTHON_VERSION) \
		--build-arg PYTHON_VERSION_ALT=$(PYTHON_VERSION_ALT) \
 		--build-arg RSC_VERSION=$(RSC_VERSION) \
 		--file connect/Dockerfile.$(IMAGE_OS) \
        -t rstudio/rstudio-connect:$(IMAGE_OS) \
        -t rstudio/rstudio-connect:$(IMAGE_OS)-$(RSC_VERSION) \
        -t rstudio/rstudio-connect:$(IMAGE_OS)-$(RSC_VERSION)--$(SHA_SHORT) \
        -t ghcr.io/rstudio/rstudio-connect:$(IMAGE_OS) \
        -t ghcr.io/rstudio/rstudio-connect:$(IMAGE_OS)-$(RSC_VERSION) \
        -t ghcr.io/rstudio/rstudio-connect:$(IMAGE_OS)-$(RSC_VERSION)--$(SHA_SHORT) \
 		connect
rsc-preview: connect-preview
connect-preview:  ## Build RSC preview image
	echo $(BRANCH)
	echo $(PREVIEW_TAG_PREFIX)
	docker buildx build \
		--build-arg R_VERSION=$(R_VERSION) \
		--build-arg R_VERSION_ALT=$(R_VERSION_ALT) \
		--build-arg PYTHON_VERSION=$(PYTHON_VERSION) \
		--build-arg PYTHON_VERSION_ALT=$(PYTHON_VERSION_ALT) \
 		--build-arg RSC_VERSION=$(RSC_VERSION) \
 		--file connect/Dockerfile.$(IMAGE_OS) \
        -t rstudio/rstudio-connect$(PREVIEW_IMAGE_SUFFIX):$(PREVIEW_TAG_PREFIX)$(IMAGE_OS)-$(PREVIEW_TYPE) \
        -t rstudio/rstudio-connect$(PREVIEW_IMAGE_SUFFIX):$(PREVIEW_TAG_PREFIX)$(IMAGE_OS)-$(RSC_VERSION) \
        -t ghcr.io/rstudio/rstudio-connect$(PREVIEW_IMAGE_SUFFIX):$(PREVIEW_TAG_PREFIX)$(IMAGE_OS)-$(PREVIEW_TYPE) \
        -t ghcr.io/rstudio/rstudio-connect$(PREVIEW_IMAGE_SUFFIX):$(PREVIEW_TAG_PREFIX)$(IMAGE_OS)-$(RSC_VERSION) \
 		connect
lint-rsc: lint-connect
lint-connect:
	just lint connect $(IMAGE_OS)
test-rsc: test-connect
test-connect: rsc
	IMAGE_NAME=rstudio/rstudio-connect:$(IMAGE_OS)-$(RSC_VERSION) \
	docker-compose -f ./connect/docker-compose.test.yml run sut
test-rsc-i: test-connect-i
test-connect-i: rsc
	IMAGE_NAME=rstudio/rstudio-connect:$(IMAGE_OS)-$(RSC_VERSION) \
	docker-compose -f ./connect/docker-compose.test.yml run sut bash
run-rsc: run-connect
run-connect: rsc  ## Run RSC container
	docker rm -f rstudio-connect
	docker run -it --privileged \
		--name rstudio-connect \
		-p 3939:3939 \
		-v $(CURDIR)/data/rsc:/var/lib/rstudio-connect \
		-v $(CURDIR)/connect/rstudio-connect.gcfg:/etc/rstudio-connect/rstudio-connect.gcfg \
		-e RSC_LICENSE=$(RSC_LICENSE) \
		rstudio/rstudio-connect:$(IMAGE_OS)-$(RSC_VERSION) $(CMD)


### RStudio Package Manager ###
rspm: package-manager
package-manager:  ## Build RSPM image
	docker buildx build \
		-t rstudio/rstudio-package-manager:$(RSPM_VERSION) \
		--build-arg R_VERSION=$(R_VERSION) \
		--build-arg RSPM_VERSION=$(RSPM_VERSION) \
		--file package-manager/Dockerfile.$(IMAGE_OS) \
        -t rstudio/rstudio-package-manager$(IMAGE_SUFFIX):$(IMAGE_OS) \
        -t rstudio/rstudio-package-manager$(IMAGE_SUFFIX):$(IMAGE_OS)-$(RSPM_VERSION) \
        -t rstudio/rstudio-package-manager$(IMAGE_SUFFIX):$(IMAGE_OS)-$(RSPM_VERSION)--$(SHA_SHORT) \
        -t ghcr.io/rstudio/rstudio-package-manager$(IMAGE_SUFFIX):$(IMAGE_OS) \
        -t ghcr.io/rstudio/rstudio-package-manager$(IMAGE_SUFFIX):$(IMAGE_OS)-$(RSPM_VERSION) \
        -t ghcr.io/rstudio/rstudio-package-manager$(IMAGE_SUFFIX):$(IMAGE_OS)-$(RSPM_VERSION)--$(SHA_SHORT) \
		package-manager
rspm-preview: package-manager
package-manager-preview:  ## Build RSPM preview image
	docker buildx build \
		-t rstudio/rstudio-package-manager:$(RSPM_VERSION) \
		--build-arg R_VERSION=$(R_VERSION) \
		--build-arg RSPM_VERSION=$(RSPM_VERSION) \
		--file package-manager/Dockerfile.$(IMAGE_OS) \
        -t rstudio/rstudio-package-manager$(PREVIEW_IMAGE_SUFFIX):$(PREVIEW_TAG_PREFIX)$(IMAGE_OS)-$(PREVIEW_TYPE) \
        -t rstudio/rstudio-package-manager$(PREVIEW_IMAGE_SUFFIX):$(PREVIEW_TAG_PREFIX)$(IMAGE_OS)-$(RSPM_VERSION) \
        -t ghcr.io/rstudio/rstudio-package-manager$(PREVIEW_IMAGE_SUFFIX):$(PREVIEW_TAG_PREFIX)$(IMAGE_OS)-$(PREVIEW_TYPE) \
        -t ghcr.io/rstudio/rstudio-package-manager$(PREVIEW_IMAGE_SUFFIX):$(PREVIEW_TAG_PREFIX)$(IMAGE_OS)-$(RSPM_VERSION) \
		package-manager
lint-rspm: lint-package-manager
lint-package-manager:
	just lint package-manager $(IMAGE_OS)
test-rspm: test-package-manager
test-package-manager: rspm
	IMAGE_NAME=rstudio/rstudio-package-manager:$(RSPM_VERSION) \
	docker-compose -f ./package-manager/docker-compose.test.yml run sut
test-rspm-i: test-package-manager-i
test-package-manager-i: rspm
	IMAGE_NAME=rstudio/rstudio-package-manager:$(RSPM_VERSION) \
	docker-compose -f ./package-manager/docker-compose.test.yml run sut bash
run-rspm: run-package-manager
run-package-manager: rspm  ## Run RSPM container
	docker rm -f rstudio-package-manager
	docker run -it \
		--name rstudio-package-manager \
		-p 4242:4242 \
		-v $(CURDIR)/data/rspm:/data \
		-v $(CURDIR)/package-manager/rstudio-pm.gcfg:/etc/rstudio-pm/rstudio-pm.gcfg \
		-e RSPM_LICENSE=$(RSPM_LICENSE)  \
		rstudio/rstudio-package-manager:$(RSPM_VERSION) $(CMD)


### r-session-complete ###
r-session-complete:  ## Build r-session-complete image
	docker buildx build \
		--build-arg R_VERSION=$(R_VERSION_ALT) \  # FIXME(ianpittwood): Make this successfully use `R_VERSION` instead of `R_VERSION_ALT`, currently fails tests
		--build-arg PYTHON_VERSION=$(PYTHON_VERSION) \
		--build-arg RSW_VERSION=$(RSW_VERSION) \
		--build-arg RSW_DOWNLOAD_URL=`just _rsw-download-url release $(IMAGE_OS)` \
		--file r-session-complete/Dockerfile.$(IMAGE_OS) \
        -t rstudio/r-session-complete$(IMAGE_SUFFIX):$(IMAGE_OS) \
        -t rstudio/r-session-complete$(IMAGE_SUFFIX):$(IMAGE_OS)-$(RSW_TAG_VERSION) \
        -t rstudio/r-session-complete$(IMAGE_SUFFIX):$(IMAGE_OS)-$(RSW_TAG_VERSION)--$(SHA_SHORT) \
        -t ghcr.io/rstudio/r-session-complete$(IMAGE_SUFFIX):$(IMAGE_OS) \
        -t ghcr.io/rstudio/r-session-complete$(IMAGE_SUFFIX):$(IMAGE_OS)-$(RSW_TAG_VERSION) \
        -t ghcr.io/rstudio/r-session-complete$(IMAGE_SUFFIX):$(IMAGE_OS)-$(RSW_TAG_VERSION)--$(SHA_SHORT) \
		r-session-complete
r-session-complete-preview:  ## Build r-session-complete preview image
	docker buildx build \
		--build-arg R_VERSION=$(R_VERSION_ALT) \  # FIXME(ianpittwood): Make this successfully use `R_VERSION` instead of `R_VERSION_ALT`, currently fails tests
		--build-arg PYTHON_VERSION=$(PYTHON_VERSION) \
		--build-arg RSW_VERSION=$(RSW_VERSION) \
		--build-arg RSW_DOWNLOAD_URL=`just _rsw-download-url $(PREVIEW_TYPE) $(IMAGE_OS)` \
		--file r-session-complete/Dockerfile.$(IMAGE_OS) \
        -t rstudio/r-session-complete$(PREVIEW_IMAGE_SUFFIX):$(PREVIEW_TAG_PREFIX)$(IMAGE_OS)-$(PREVIEW_TYPE) \
        -t rstudio/r-session-complete$(PREVIEW_IMAGE_SUFFIX):$(PREVIEW_TAG_PREFIX)$(IMAGE_OS)-$(RSW_TAG_VERSION) \
        -t ghcr.io/rstudio/r-session-complete$(PREVIEW_IMAGE_SUFFIX):$(PREVIEW_TAG_PREFIX)$(IMAGE_OS)-$(PREVIEW_TYPE) \
        -t ghcr.io/rstudio/r-session-complete$(PREVIEW_IMAGE_SUFFIX):$(PREVIEW_TAG_PREFIX)$(IMAGE_OS)-$(RSW_TAG_VERSION) \
		r-session-complete
lint-r-session-complete:
	just lint r-session-complete $(IMAGE_OS)
test-r-session-complete: r-session-complete
	IMAGE_NAME=rstudio/r-session-complete:$(IMAGE_OS)-$(RSW_TAG_VERSION) \
	docker-compose -f ./r-session-complete/docker-compose.test.yml run sut
test-r-session-complete-i: r-session-complete
	IMAGE_NAME=rstudio/r-session-complete:$(IMAGE_OS)-$(RSW_TAG_VERSION) \
	docker-compose -f ./r-session-complete/docker-compose.test.yml run sut bash
run-r-session-complete: rsw  ## Run RSW container
	docker rm -f r-session-complete
	docker run -it \
		--name r-session-complete \
		-p 8788:8788 \
		-v /run \
		-e RSW_LICENSE=$(RSW_LICENSE) \
		rstudio/r-session-complete:$(IMAGE_OS)-$(RSW_TAG_VERSION) $(CMD)


### RStudio Workbench ###
rsw: workbench
workbench:  ## Build Workbench image
	docker buildx build \
		--build-arg R_VERSION=$(R_VERSION) \
		--build-arg R_VERSION_ALT=$(R_VERSION_ALT) \
		--build-arg PYTHON_VERSION=$(PYTHON_VERSION) \
		--build-arg PYTHON_VERSION_ALT=$(PYTHON_VERSION_ALT) \
		--build-arg RSW_VERSION=$(RSW_VERSION) \
		--build-arg RSW_DOWNLOAD_URL=`just _rsw-download-url release $(IMAGE_OS)` \
		--file workbench/Dockerfile.$(IMAGE_OS) \
        -t rstudio/rstudio-workbench$(IMAGE_SUFFIX):$(IMAGE_OS) \
        -t rstudio/rstudio-workbench$(IMAGE_SUFFIX):$(IMAGE_OS)-$(RSW_TAG_VERSION) \
        -t rstudio/rstudio-workbench$(IMAGE_SUFFIX):$(IMAGE_OS)-$(RSW_TAG_VERSION)--$(SHA_SHORT) \
        -t ghcr.io/rstudio/rstudio-workbench$(IMAGE_SUFFIX):$(IMAGE_OS) \
        -t ghcr.io/rstudio/rstudio-workbench$(IMAGE_SUFFIX):$(IMAGE_OS)-$(RSW_TAG_VERSION) \
        -t ghcr.io/rstudio/rstudio-workbench$(IMAGE_SUFFIX):$(IMAGE_OS)-$(RSW_TAG_VERSION)--$(SHA_SHORT) \
		workbench
rsw-preview: workbench
workbench-preview:  ## Build Workbench preview image
	docker buildx build \
		--build-arg R_VERSION=$(R_VERSION) \
		--build-arg R_VERSION_ALT=$(R_VERSION_ALT) \
		--build-arg PYTHON_VERSION=$(PYTHON_VERSION) \
		--build-arg PYTHON_VERSION_ALT=$(PYTHON_VERSION_ALT) \
		--build-arg RSW_VERSION=$(RSW_VERSION) \
		--build-arg RSW_DOWNLOAD_URL=`just _rsw-download-url $(PREVIEW_TYPE) $(IMAGE_OS)` \
		--file workbench/Dockerfile.$(IMAGE_OS) \
        -t rstudio/rstudio-workbench$(PREVIEW_IMAGE_SUFFIX):$(PREVIEW_TAG_PREFIX)$(IMAGE_OS)-$(PREVIEW_TYPE) \
        -t rstudio/rstudio-workbench$(PREVIEW_IMAGE_SUFFIX):$(PREVIEW_TAG_PREFIX)$(IMAGE_OS)-$(RSW_TAG_VERSION) \
        -t ghcr.io/rstudio/rstudio-workbench$(PREVIEW_IMAGE_SUFFIX):$(PREVIEW_TAG_PREFIX)$(IMAGE_OS)-$(PREVIEW_TYPE) \
        -t ghcr.io/rstudio/rstudio-workbench$(PREVIEW_IMAGE_SUFFIX):$(PREVIEW_TAG_PREFIX)$(IMAGE_OS)-$(RSW_TAG_VERSION) \
		workbench
lint-rsw: lint-workbench
lint-workbench:
	just lint workbench $(IMAGE_OS)
test-rsw: test-workbench
test-workbench: rsw
	IMAGE_NAME=rstudio/rstudio-workbench:$(IMAGE_OS)-$(RSW_TAG_VERSION) \
	docker-compose -f ./workbench/docker-compose.test.yml run sut
test-rsw-i: test-workbench-i
test-workbench-i: rsw
	IMAGE_NAME=rstudio/rstudio-workbench:$(IMAGE_OS)-$(RSW_TAG_VERSION) \
 	docker-compose -f docker-compose.test.yml run sut bash
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


### RStudio Workbench for Azure ###
rsw-azure: workbench-azure
workbench-azure:  ## Build Workbench for Microsoft Azure ML image
	docker buildx build \
		--build-arg R_VERSION=$(R_VERSION) \
		--build-arg R_VERSION_ALT=$(R_VERSION_ALT) \
		--build-arg PYTHON_VERSION=$(PYTHON_VERSION) \
		--build-arg PYTHON_VERSION_ALT=$(PYTHON_VERSION_ALT) \
		--build-arg RSW_VERSION=$(RSW_VERSION) \
		--build-arg RSW_DOWNLOAD_URL=`just _rsw-download-url release $(IMAGE_OS)` \
		--file workbench-for-microsoft-azure-ml/Dockerfile.$(IMAGE_OS) \
        -t rstudio/rstudio-workbench-for-microsoft-azure-ml$(IMAGE_SUFFIX):$(IMAGE_OS) \
        -t rstudio/rstudio-workbench-for-microsoft-azure-ml$(IMAGE_SUFFIX):$(IMAGE_OS)-$(RSW_TAG_VERSION) \
        -t rstudio/rstudio-workbench-for-microsoft-azure-ml$(IMAGE_SUFFIX):$(IMAGE_OS)-$(RSW_TAG_VERSION)--$(SHA_SHORT) \
        -t ghcr.io/rstudio/rstudio-workbench-for-microsoft-azure-ml$(IMAGE_SUFFIX):$(IMAGE_OS) \
        -t ghcr.io/rstudio/rstudio-workbench-for-microsoft-azure-ml$(IMAGE_SUFFIX):$(IMAGE_OS)-$(RSW_TAG_VERSION) \
        -t ghcr.io/rstudio/rstudio-workbench-for-microsoft-azure-ml$(IMAGE_SUFFIX):$(IMAGE_OS)-$(RSW_TAG_VERSION)--$(SHA_SHORT) \
		workbench-for-microsoft-azure-ml
rsw-azure-preview: workbench-azure
workbench-azure-preview:  ## Build Workbench for Microsoft Azure ML image
	docker buildx build \
		--build-arg R_VERSION=$(R_VERSION) \
		--build-arg R_VERSION_ALT=$(R_VERSION_ALT) \
		--build-arg PYTHON_VERSION=$(PYTHON_VERSION) \
		--build-arg PYTHON_VERSION_ALT=$(PYTHON_VERSION_ALT) \
		--build-arg RSW_VERSION=$(RSW_VERSION) \
		--build-arg RSW_DOWNLOAD_URL=`just _rsw-download-url $(PREVIEW_TYPE) $(IMAGE_OS)` \
		--file workbench-for-microsoft-azure-ml/Dockerfile.$(IMAGE_OS) \
        -t rstudio/rstudio-workbench-for-microsoft-azure-ml$(PREVIEW_IMAGE_SUFFIX):$(PREVIEW_TAG_PREFIX)$(IMAGE_OS)-$(PREVIEW_TYPE) \
        -t rstudio/rstudio-workbench-for-microsoft-azure-ml$(PREVIEW_IMAGE_SUFFIX):$(PREVIEW_TAG_PREFIX)$(IMAGE_OS)-$(RSW_TAG_VERSION) \
        -t ghcr.io/rstudio/rstudio-workbench-for-microsoft-azure-ml$(PREVIEW_IMAGE_SUFFIX):$(PREVIEW_TAG_PREFIX)$(IMAGE_OS)-$(PREVIEW_TYPE) \
        -t ghcr.io/rstudio/rstudio-workbench-for-microsoft-azure-ml$(PREVIEW_IMAGE_SUFFIX):$(PREVIEW_TAG_PREFIX)$(IMAGE_OS)-$(RSW_TAG_VERSION) \
		workbench-for-microsoft-azure-ml
lint-rsw-azure: lint-workbench-azure
lint-workbench-azure:
	just lint workbench-for-microsoft-azure-ml $(IMAGE_OS)
test-rsw-azure: test-workbench-azure
test-workbench-azure: rsw-azure
	IMAGE_NAME=rstudio/rstudio-workbench-for-microsoft-azure-ml:$(IMAGE_OS)-$(RSW_TAG_VERSION) \
	docker-compose -f ./workbench-for-microsoft-azure-mldocker-compose.test.yml run sut
test-rsw-azure-i: test-workbench-azure-i
test-workbench-azure-i: rsw-azure
	IMAGE_NAME=rstudio/rstudio-workbench-for-microsoft-azure-ml:$(IMAGE_OS)-$(RSW_TAG_VERSION) \
	docker-compose -f ./workbench-for-microsoft-azure-mldocker-compose.test.yml run sut bash


### Floating License Server ###
float:
	docker-compose -f helper/float/docker-compose.yml build
run-float: run-floating-lic-server
run-floating-lic-server:  ## [DO NOT USE IN PRODUCTION] Run the floating license server for pro products
	RSW_FLOAT_LICENSE=$(RSW_FLOAT_LICENSE) RSC_FLOAT_LICENSE=$(RSC_FLOAT_LICENSE) RSPM_FLOAT_LICENSE=$(RSPM_FLOAT_LICENSE) SSP_FLOAT_LICENSE=$(SSP_FLOAT_LICENSE) \
	docker-compose -f helper/float/docker-compose.yml up


### Help menu ###
help:  ## Show this help menu
	@grep -E '^[0-9a-zA-Z_-]+:.*?##.*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?##"; OFS="\t\t"}; {printf "\033[36m%-30s\033[0m %s\n", $$1, ($$2==""?"":$$2)}'


.PHONY: workbench \
		connect \
		package-manager \
		r-session-complete \
		float
