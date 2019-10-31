R_VERSION ?= 3.6

RSP_VERSION ?= 1.2.5001-3
RSC_VERSION ?= 1.7.8-7
RSPM_VERSION ?= 1.0.14-7

RSP_LICENSE ?= ""
RSC_LICENSE ?= ""
RSPM_LICENSE ?= ""

CMD ?= ""

all: help

images: server-pro connect package-manager  ## Build all images
	# docker-compose build

server-pro:  ## Build RSP image
	docker build -t rstudio/server-pro:$(RSP_VERSION) --build-arg R_VERSION=$(R_VERSION) --build-arg RSP_VERSION=$(RSP_VERSION) server-pro

run-server-pro:  ## Run RSP container
	docker run -it --privileged \
		-p 8787:8787 \
		-v /run \
		-e RSP_LICENSE=$(RSP_LICENSE) \
		rstudio/server-pro:$(RSP_VERSION) $(CMD)

connect:  ## Build RSC image
	docker build -t rstudio/connect:$(RSC_VERSION) --build-arg R_VERSION=$(R_VERSION) --build-arg RSC_VERSION=$(RSC_VERSION) connect

run-connect:  ## Run RSC container
	docker run -it --privileged \
		-p 3939:3939 \
		-v $(CURDIR)/data/rsc:/var/lib/rstudio-connect \
		-v $(CURDIR)/connect/rstudio-connect.gcfg:/etc/rstudio-connect/rstudio-connect.gcfg \
		-e RSC_LICENSE=$(RSC_LICENSE) \
		rstudio/connect:$(RSC_VERSION) $(CMD)

package-manager:  ## Build RSPM image
	docker build -t rstudio/package-manager:$(RSPM_VERSION) --build-arg R_VERSION=$(R_VERSION) --build-arg RSPM_VERSION=$(RSPM_VERSION) package-manager

run-package-manager:  ## Run RSPM container
	docker run -it --privileged \
		-p 4242:4242 \
		-v $(CURDIR)/data/rspm:/data \
		-v $(CURDIR)/package-manager/rstudio-pm.gcfg:/etc/rstudio-pm/rstudio-pm.gcfg \
		-e RSPM_LICENSE=$(RSPM_LICENSE)  \
		rstudio/package-manager:$(RSPM_VERSION) $(CMD)

help:  ## Show this help menu
	@grep -E '^[0-9a-zA-Z_-]+:.*?##.*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?##"; OFS="\t\t"}; {printf "\033[36m%-30s\033[0m %s\n", $$1, ($$2==""?"":$$2)}'

.PHONY: server-pro run-server-pro connect run-connect package-manager run-package-manager
