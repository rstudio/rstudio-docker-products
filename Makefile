R_VERSION ?= 3.6.2
R_VERSION_ALT ?= 4.1.0

PYTHON_VERSION ?= 3.9.5
PYTHON_VERSION_ALT ?= 3.8.10

RSW_VERSION ?= 2022.02.2+485.pro2
RSC_VERSION ?= 2022.04.1
RSPM_VERSION ?= 2022.04.0-7

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

RSW_TAG_VERSION=`echo "$(RSW_VERSION)" | sed -e 's/\+/-/'`

all: help


images: workbench connect package-manager  ## Build all images
	docker-compose build


update-versions:  ## Update the version files for all products
	@sed $(SED_FLAGS) "s/^RSW_VERSION=.*/RSW_VERSION=${RSW_VERSION}/g" workbench/.env
	@sed $(SED_FLAGS) "s/^RSW_VERSION=.*/RSW_VERSION=${RSW_VERSION}/g" r-session-complete/bionic/.env
	@sed $(SED_FLAGS) "s/^RSW_VERSION=.*/RSW_VERSION=${RSW_VERSION}/g" r-session-complete/centos7/.env
	@sed $(SED_FLAGS) "s/^RSC_VERSION=.*/RSC_VERSION=${RSC_VERSION}/g" connect/.env
	@sed $(SED_FLAGS) "s/^RSPM_VERSION=.*/RSPM_VERSION=${RSPM_VERSION}/g" package-manager/.env
	@sed $(SED_FLAGS) "s/^ARG RSW_VERSION=.*/ARG RSW_VERSION=${RSW_VERSION}/g" workbench/Dockerfile
	@sed $(SED_FLAGS) "s/^ARG RSC_VERSION=.*/ARG RSC_VERSION=${RSC_VERSION}/g" connect/Dockerfile
	@sed $(SED_FLAGS) "s/^ARG RSC_VERSION=.*/ARG RSC_VERSION=${RSC_VERSION}/g" connect-content-init/Dockerfile
	@sed $(SED_FLAGS) "s/^ARG RSPM_VERSION=.*/ARG RSPM_VERSION=${RSPM_VERSION}/g" package-manager/Dockerfile
	@sed $(SED_FLAGS) "s/^RSPM_VERSION:.*/RSPM_VERSION: ${RSPM_VERSION}/g" docker-compose.yml
	@sed $(SED_FLAGS) "s/RSPM_VERSION:.*/RSPM_VERSION: ${RSPM_VERSION}/g" docker-compose.yml
	@sed $(SED_FLAGS) "s/rstudio\/rstudio-package-manager:.*/rstudio\/rstudio-package-manager:${RSPM_VERSION}/g" docker-compose.yml
	@sed $(SED_FLAGS) "s/RSC_VERSION:.*/RSC_VERSION: ${RSC_VERSION}/g" docker-compose.yml
	@sed $(SED_FLAGS) "s/rstudio\/rstudio-connect:.*/rstudio\/rstudio-connect:${RSC_VERSION}/g" docker-compose.yml
	@sed $(SED_FLAGS) "s/RSW_VERSION:.*/RSW_VERSION: ${RSW_VERSION}/g" docker-compose.yml
	@sed $(SED_FLAGS) "s/rstudio\/rstudio-workbench:.*/rstudio\/rstudio-workbench:${RSW_TAG_VERSION}/g" docker-compose.yml
	@sed $(SED_FLAGS) "s/^R_VERSION:.*/R_VERSION=${R_VERSION}/g" workbench/Dockerfile
	@sed $(SED_FLAGS) "s/^R_VERSION:.*/R_VERSION=${R_VERSION}/g" connect/Dockerfile
	@sed $(SED_FLAGS) "s/^R_VERSION:.*/R_VERSION=${R_VERSION}/g" package-manager/Dockerfile
	@sed $(SED_FLAGS) "s|^RVersion.*=.*|RVersion = /opt/R/${R_VERSION}/|g" package-manager/rstudio-pm.gcfg
	@sed $(SED_FLAGS) "s/^ARG RSW_VERSION=.*/ARG RSW_VERSION=${RSW_VERSION}/g" r-session-complete/bionic/Dockerfile
	@sed $(SED_FLAGS) "s/^ARG RSW_VERSION=.*/ARG RSW_VERSION=${RSW_VERSION}/g" r-session-complete/centos7/Dockerfile


rsw: workbench
workbench:  ## Build Workbench image
	docker build -t rstudio/rstudio-workbench:$(RSW_TAG_VERSION) --build-arg R_VERSION=$(R_VERSION) --build-arg RSW_VERSION=$(RSW_VERSION) workbench

rsw-hook:
	cd ./workbench && \
	DOCKERFILE_PATH=Dockerfile \
	IMAGE_NAME=rstudio/rstudio-workbench$(RSW_VERSION) \
	./hooks/build

test-rsw: test-workbench
test-workbench:
	cd ./workbench && IMAGE_NAME=rstudio/rstudio-workbench$(RSW_VERSION) docker-compose -f docker-compose.test.yml run sut
test-rsw-i: test-workbench-i
test-workbench-i:
	cd ./workbench && IMAGE_NAME=rstudio/rstudio-workbench:$(RSW_VERSION) docker-compose -f docker-compose.test.yml run sut bash


run-rsw: run-workbench
run-workbench:  ## Run RSW container
	docker rm -f rstudio-workbench
	docker run -it --privileged \
		--name rstudio-workbench \
		-p 8787:8787 \
		-v $(PWD)/workbench/conf:/etc/rstudio/ \
		-v /run \
		-e RSW_LICENSE=$(RSW_LICENSE) \
		rstudio/rstudio-workbench:$(RSW_VERSION) $(CMD)


rsc: connect
connect:  ## Build RSC image
	docker build -t rstudio/rstudio-connect:$(RSC_VERSION) --build-arg R_VERSION=$(R_VERSION) --build-arg RSC_VERSION=$(RSC_VERSION) connect

test-rsc: test-connect
test-connect:
	cd ./connect && IMAGE_NAME=rstudio/rstudio-connect:$(RSC_VERSION) docker-compose -f docker-compose.test.yml run sut
test-rsc-i: test-connect-i
test-connect-i:
	cd ./connect && IMAGE_NAME=rstudio/rstudio-connect:$(RSC_VERSION) docker-compose -f docker-compose.test.yml run sut bash


run-rsc: run-connect
run-connect:  ## Run RSC container
	docker rm -f rstudio-connect
	docker run -it --privileged \
		--name rstudio-connect \
		-p 3939:3939 \
		-v $(CURDIR)/data/rsc:/var/lib/rstudio-connect \
		-v $(CURDIR)/connect/rstudio-connect.gcfg:/etc/rstudio-connect/rstudio-connect.gcfg \
		-e RSC_LICENSE=$(RSC_LICENSE) \
		rstudio/rstudio-connect:$(RSC_VERSION) $(CMD)


rspm: package-manager
package-manager:  ## Build RSPM image
	docker build -t rstudio/rstudio-package-manager:$(RSPM_VERSION) --build-arg R_VERSION=$(R_VERSION) --build-arg RSPM_VERSION=$(RSPM_VERSION) package-manager


test-rspm: test-package-manager
test-package-manager:
	cd ./package-manager && IMAGE_NAME=rstudio/rstudio-package-manager:$(RSPM_VERSION) docker-compose -f docker-compose.test.yml run sut
test-rspm-i: test-package-manager-i
test-package-manager-i:
	cd ./package-manager && IMAGE_NAME=rstudio/rstudio-package-manager:$(RSPM_VERSION) docker-compose -f docker-compose.test.yml run sut bash


run-rspm: run-package-manager
run-package-manager:  ## Run RSPM container
	docker rm -f rstudio-package-manager
	docker run -it --privileged \
		--name rstudio-package-manager \
		-p 4242:4242 \
		-v $(CURDIR)/data/rspm:/data \
		-v $(CURDIR)/package-manager/rstudio-pm.gcfg:/etc/rstudio-pm/rstudio-pm.gcfg \
		-e RSPM_LICENSE=$(RSPM_LICENSE)  \
		rstudio/rstudio-package-manager:$(RSPM_VERSION) $(CMD)


test-all: rspm test-rspm rsc test-rsc rsp test-rsw

test-azure:
	cd ./helper/workbench-for-microsoft-azure-ml && IMAGE_NAME=ghcr.io/rstudio/rstudio-workbench-for-microsoft-azure-ml:latest docker-compose -f docker-compose.test.yml run sut
test-azure-i:
	cd ./helper/workbench-for-microsoft-azure-ml && IMAGE_NAME=ghcr.io/rstudio/rstudio-workbench-for-microsoft-azure-ml:latest docker-compose -f docker-compose.test.yml run sut bash

float:
	docker-compose -f helper/float/docker-compose.yml build

run-float: run-floating-lic-server
run-floating-lic-server:  ## Run the floating license server for pro products
	RSW_FLOAT_LICENSE=$(RSW_FLOAT_LICENSE) RSC_FLOAT_LICENSE=$(RSC_FLOAT_LICENSE) RSPM_FLOAT_LICENSE=$(RSPM_FLOAT_LICENSE) SSP_FLOAT_LICENSE=$(SSP_FLOAT_LICENSE) \
	docker-compose -f helper/float/docker-compose.yml up


help:  ## Show this help menu
	@grep -E '^[0-9a-zA-Z_-]+:.*?##.*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?##"; OFS="\t\t"}; {printf "\033[36m%-30s\033[0m %s\n", $$1, ($$2==""?"":$$2)}'


.PHONY: workbench rsw run-workbench connect rsc run-connect package-manager rspm run-package-manager run-floatating-lic-server
