# Quick reference

* Maintained by: [the Posit Docker team](https://github.com/rstudio/rstudio-docker-products)
* Where to get help: [our Github Issues page](https://github.com/rstudio/rstudio-docker-products/issues)
* RStudio Package Manager image: [Docker Hub](https://hub.docker.com/r/rstudio/rstudio-package-manager)

# Supported tags and respective Dockerfile links

* [`jammy`, `ubuntu2204`, `jammy-2023.12.0`, `ubuntu2204-2023.12.0`](https://github.com/rstudio/rstudio-docker-products/blob/main/package-manager/Dockerfile.ubuntu2204)

# What is RStudio Package Manager?

Posit Package Manager, formerly RStudio Package Manager, is a repository management server to organize and centralize 
R packages across your team, department, or entire organization. Get offline access to CRAN, automate CRAN syncs, 
share local packages, restrict package access, find packages across repositories, and more. Experience reliable and 
consistent package management, optimized for teams who use R.

The following documentation helps an administrator install and configure Package Manager. It provides information for 
installing the product on different operating systems, upgrading, and configuring Package Manager.

# Notice for support

1. This image may introduce **BREAKING** changes; as such we recommend:
   - Avoid using the `{operating-system}` tags to avoid unexpected version changes, and
   - Always read through the [NEWS](./NEWS.md) to understand the changes before updating.
1. Outdated images will be removed periodically from DockerHub as product version updates are made. Please make plans to
   update at times or use your own build of the images.
1. These images are meant as a starting point for your needs. Consider creating a fork of this repo, where you can
   continue to merge in changes we make while having your own security scanning, base OS in use, or other custom
   changes. We
   provide [instructions for building](https://github.com/rstudio/rstudio-docker-products#instructions-for-building) for
   these cases.
1. The Package Manager image uses the `No Sandbox` option documented
   [here](https://docs.rstudio.com/rspm/admin/process-management/#process-management-sandboxing) by default, if you need
   a more secure option for configuring
   [Git-related package builds](https://docs.rstudio.com/rspm/admin/building-packages/) we recommend [using a system with
   sandboxing enabled](https://docs.rstudio.com/rspm/admin/process-management/#docker).
1. **Security Note:** These images are provided AS IS based on the build environment at the time their product version was released/updated. They should be reviewed and updated before production use. If your organization has a specific set of security requirements related to CVE/Vulnerability severity levels, you should plan to use the [instructions for building](https://github.com/rstudio/rstudio-docker-products#instructions-for-building) to clone this repository, and rebuild these images to your specific internal security standards.


# How to use this image

To verify basic functionality as a first step:
```bash
# Replace with valid license
export RSPM_LICENSE=XXXX-XXXX-XXXX-XXXX-XXXX-XXXX-XXXX

# Run without persistent data and using default configuration
docker run -it \
    -p 4242:4242 \
    -e RSPM_LICENSE=$RSPM_LICENSE \
    rstudio/rstudio-package-manager:ubuntu1804
```
Open [http://localhost:4242](http://localhost:4242) to access RStudio Package Manager UI.

## Overview

Note that running the RStudio Package Manager Docker image requires a valid RStudio Package Manager license.

This container includes:

1. One version of R
2. RStudio Package Manager

> NOTE: Package Manager is currently not very particular about R version. Changing the R version is rarely necessary.

## Configuration

RStudio Package Manager is configured via the`/etc/rstudio-pm/rstudio-pm.gcfg` file. You should mount this file as
a volume from the host machine. Changes will take effect when the container is restarted.

Be sure the config file has the `[HTTP].Listen` field configured. See a complete example of that file at
[`package-manager/rstudio-pm.gcfg`](./rstudio-pm.gcfg).

### Persistent Data

In order to persist Package Manager data between container restarts, configure the `Server.DataDir` option to go to
a persistent volume. The included configuration file expects a persistent volume from the host machine or your docker
orchestration system to be available at `/var/lib/rstudio-pm`. Should you wish to move this to a different path, you can change the
`Server.DataDir` option.

When changing `Server.DataDir` to a custom location, we also recommend setting `Server.LauncherDir`
to a consistent location within `Server.DataDir`, such as `{Server.DataDir}/launcher_internal`.
The default location of `Server.LauncherDir` depends on the container's hostname, which may be
different each time the container restarts.

```ini
[Server]
DataDir = /mnt/rspm/data
; Use a consistent location for the Launcher directory. The default location
; is based on the hostname, and the hostname may be different in each container.
LauncherDir = /mnt/rspm/data/launcher_internal
```

### Licensing

Using the RStudio Package Manager Docker image requires a valid license for Package Manager. You can set the license in three ways:

1. Setting the `RSPM_LICENSE` environment variable to a valid license key inside the container
2. Setting the `RSPM_LICENSE_SERVER` environment variable to a valid license server / port inside the container
3. Mounting a `/etc/rstudio-pm/license.lic` single file that contains a valid license for RStudio Package Manager

**NOTE:** the "offline activation process" is not supported by this image today. Offline installations will need
to explore using a license server, license file, or custom image with manual intervention.

### Environment variables

| Variable | Description | Default |
|-----|---|---|
| `RSPM_LICENSE` | License key for RStudio Package Manager, format should be: `XXXX-XXXX-XXXX-XXXX-XXXX-XXXX-XXXX` | None |
| `RSPM_LICENSE_SERVER` | Floating license server, format should be: `my.url.com:port` | None |

### Ports

| Variable | Description |
|----------|---|
| `4242`   | Default HTTP Port for RStudio Package Manager |

### Example usage

```bash
# Replace with valid license
export RSPM_LICENSE=XXXX-XXXX-XXXX-XXXX-XXXX-XXXX-XXXX

# Run without persistent data and using an external configuration
docker run -it \
    -p 4242:4242 \
    -v $PWD/package-manager/rstudio-pm.gcfg:/etc/rstudio-pm/rstudio-pm.gcfg \
    -e RSPM_LICENSE=$RSPM_LICENSE \
    rstudio/rstudio-package-manager:ubuntu1804

# Run with persistent data and using an external configuration
docker run -it \
    -p 4242:4242 \
    -v $PWD/data/rspm:/data \
    -v $PWD/package-manager/rstudio-pm.gcfg:/etc/rstudio-pm/rstudio-pm.gcfg \
    -e RSPM_LICENSE=$RSPM_LICENSE \
    rstudio/rstudio-package-manager:ubuntu1804
```

Open [http://localhost:4242](http://localhost:4242) to access RStudio Package Manager UI.

To create repositories you need to access the container directly and execute some commands.
To do this find the container ID for RSPM (using `docker ps`) and run:

```bash
docker exec -it {container-id} /bin/bash
```

Then please refer to the [RSPM guide](https://docs.rstudio.com/rspm/admin/) on how
to [create and manage](https://docs.rstudio.com/rspm/admin/getting-started/configuration/) your repositories.

## Caveats of product licensing in containers

*Note: This section **does not** apply to activations using license files.*

There is currently a known licensing bug when using our products in containers. If the container is not stopped
gracefully, the license deactivation step may fail or be skipped. Failing to deactivate the license can result in a 
"license leak" where a product activation is used up and cannot be deactivated using traditional methods as the 
activation state on the container has been lost.

To avoid "leaking" licenses, we encourage users not to force kill containers and to use `--stop-timeout 120` and 
`--time 120` for `docker run` and `docker stop` commands respectively. This helps ensure the deactivation script has 
ample time to run properly.

In some situations, it can be difficult or impossible to avoid a hard termination (e.g. power failure, 
critical error on host). Unfortunately, any of these cases can still cause a license to leak an activation. To help
prevent a license leak in these situations, users can mount the following directories to persistent storage to preserve
the license state data across restarts of the container. **These directories differ between products.**

* License Key
  * `/home/rstudio-pm/.local`
  * `/home/rstudio-pm/.prof`
  * `/home/rstudio-pm/.rstudio-pm`
* Floating License
  * `/home/rstudio-pm/.TurboFloat`

Please note that the files created in these directories are hardware locked and non-transferable between hosts. Due to
the nature of the hardware fingerprinting algorithm, any low-level changes to the host or container can cause existing
license state files to invalidate. To avoid this problem, we advise that product containers are gracefully shutdown
and allowed to deactivate prior to changing any hardware or firmware on the host (e.g. upgrading a network card or 
updating BIOS) or the container (e.g. changing the network driver used or the allocated number of CPU cores).

While preserving license state data *can* help avoid license leaks across restarts, it's not a guarantee. If you run
into issues with your license, please do not hesitate to [contact Posit support](https://support.posit.co/hc/en-us).

While neither of these solutions will eliminate the problem, they should help mitigate it. We are still investigating a 
long-term solution.

# Licensing

The license associated with the RStudio Docker Products repository is located
[in LICENSE.md](https://github.com/rstudio/rstudio-docker-products/blob/main/LICENSE.md).

As is the case with all container images, the images themselves also contain other software which may be under other
licenses (i.e. bash, linux, system libraries, etc., along with any other direct or indirect dependencies of the primary
software being contained).

It is an image user's responsibility to ensure that use of this image (and any of its dependent layers) complies with
all relevant licenses for the software contained in the image.
