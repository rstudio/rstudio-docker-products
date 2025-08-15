# Quick reference

* Maintained by: [the Posit Docker team](https://github.com/rstudio/rstudio-docker-products)
* Where to get help: [our Github Issues page](https://github.com/rstudio/rstudio-docker-products/issues), 
  [the Posit Workbench Documentation](https://docs.posit.co/ide/), 
  [the Posit Community Forum](https://forum.posit.co/c/posit-professional-hosted/posit-workbench/69), 
  or [Posit Support](https://support.posit.co/hc/en-us)
* Posit Workbench image: [Docker Hub](https://hub.docker.com/r/rstudio/rstudio-workbench), 
  [GHCR](https://github.com/rstudio/rstudio-docker-products/pkgs/container/rstudio-workbench)
* Posit r-session-complete image: [Docker Hub](https://hub.docker.com/r/rstudio/r-session-complete), 
  [GHCR](https://github.com/rstudio/rstudio-docker-products/pkgs/container/r-session-complete)

# Supported tags and respective Dockerfile links

* [`jammy`, `ubuntu2204`, `jammy-2025.05.1`, `ubuntu2204-2025.05.1`](https://github.com/rstudio/rstudio-docker-products/blob/main/workbench/Dockerfile.ubuntu2204)

# What is Posit Workbench?

Posit Workbench, formerly RStudio Workbench, is the preferred data analysis and integrated development experience for
professional R users and data science teams who use R and Python. Posit Workbench enables the collaboration,
centralized management, metrics, security, and commercial support that professional data science teams need to operate
at scale.

Some of the functionality that Workbench provides is:

* The ability to develop in Workbench and Jupyter
* Load balancing
* Tutorial API
* Data connectivity and Posit Professional Drivers
* Collaboration and project sharing
* Scale with Kubernetes and SLURM
* Authentication, access, & security
* Run multiple concurrent R and Python sessions
* Remote execution with Launcher
* Auditing and monitoring
* Advanced R and Python session management

For more information on running Posit Workbench in your organization please visit 
https://posit.co/products/enterprise/workbench/.

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
1. **Security Note:** These images are provided AS IS based on the build environment at the time their product version 
   was released/updated. They should be reviewed and updated before production use. If your organization has a specific 
   set of security requirements related to CVE/Vulnerability severity levels, you should plan to use the 
   [instructions for building](https://github.com/rstudio/rstudio-docker-products#instructions-for-building) to clone this repository, and rebuild these images to your specific internal 
   security standards.


# How to use this image

Below is a very simple example for running Workbench locally in Docker using a product license key.

```
# Replace with valid license
export RSW_LICENSE=XXXX-XXXX-XXXX-XXXX-XXXX-XXXX-XXXX

# Run without persistent data using default configuration
docker run -it \
    -p 8787:8787 \
    -e RSW_LICENSE=$RSW_LICENSE \
    rstudio/rstudio-workbench:ubuntu2204
```


Open [http://localhost:8787](http://localhost:8787) to access Posit Workbench. The default username and password are
`rstudio`.

## Overview

Note that running the Posit Workbench Docker image requires a valid Posit Workbench license.

This container includes:

1. Two versions of R
2. Two versions of Python
3. Quarto
4. Posit Professional Drivers
5. Posit Workbench

## Configuration

Posit Workbench is configured via config files in the `/etc/rstudio` directory. Mount this directory as
a volume from the host machine. Changes will take effect when the container is restarted.

You can review possible Posit Workbench configuration [in the documentation](https://docs.posit.co/ide/).

See a complete example of server configuration at `workbench/conf`.

### Persistent Data

In order to persist user files between container restarts please mount the `/home` directory from a persistent volume on the host
machine or your docker orchestration system.

### Product Licensing

The Posit Workbench Docker image requires a valid license, which can be set in three ways:

1. Setting the `RSW_LICENSE` environment variable to a valid license key inside the container
2. Setting the `RSW_LICENSE_SERVER` environment variable to a valid license server / port inside the container
3. Mounting a license file at `/var/lib/rstudio-server/*.lic` or a different path specified using 
   `RSW_LICENSE_FILE_PATH` that contains a valid license for Posit Workbench

**NOTE:** Offline installations will need to use a floating license server, license file, or custom image with manual 
intervention to successfully activate the instance.

#### Example usage with a license file

The container will automatically look for a license file at `/var/lib/rstudio-server/*.lic` and will attempt to use it
for activation if present. This example uses a bind mount to provide the license file from the host machine.

```bash
docker run -it --privileged \
    -p 8787:8787 \
    --mount type=bind,ro,src=<path to license file>,dst=/var/lib/rstudio-server/rstudio-server.lic \
    rstudio/rstudio-workbench:ubuntu2204
```

Alternatively, the license file's path in the container can be provided using the `RSW_LICENSE_FILE_PATH` environment 
variable. If provided, the container will attempt to find and activate from the file at the given path.

```bash
docker run -it --privileged \
    -p 8787:8787 \
    -e RSW_LICENSE_FILE_PATH=/opt/license.lic \
    --mount type=bind,ro,src=<path to license file>,dst=/opt/license.lic \
    rstudio/rstudio-workbench:ubuntu2204
```

If the license file does not successfully activate, the container should fail to start under most circumstances. You can
still verify the container's licensing status by running the `status` command against the `license-manager` binary.

```bash
$ docker exec -it <container name> /lib/rstudio-server/bin/license-manager status
TTY detected. Printing informational message about logging configuration. Logging configuration loaded from '/etc/rstudio/logging.conf'. Logging to '/var/log/rstudio/rstudio-server/license-manager.log'.
RStudio License Manager 2024.04.2+764.pro1

-- License file status --

Status: Activated
Product-Key: XXXX-XXXX-XXXX-XXXX-XXXX-XXXX-XXXX
Has-Key: Yes
Has-Trial: No
Tier: Tier Name
SKU-Year: 2024
Enable-Launcher: 1
Users: 0
User-Activity-Days: 365
Shiny-Users: 0
Allow-APIs: 1
Anonymous-Servers: 0
Unrestricted-Servers: 0
Licensee: Company Name
License-File: /var/lib/rstudio-server/rstudio-server.lic
Expiration: YYYY-MM-DD HH:mm:ss
Days-Left: XXX
License-Engine: 1.0.0.0
License-Scope: System

-- Local license status --

Trial-Type: Verified
Status: Expired
Has-Key: No
Has-Trial: Yes
License-Scope: System
License-Engine: 4.4.3.0

-- Floating license status --

License server not in use.
```

#### Example usage with a license key

The container can also be activated using a license key by setting the `RSW_LICENSE` environment variable. 

```bash
# Replace with valid license
export RSW_LICENSE=XXXX-XXXX-XXXX-XXXX-XXXX-XXXX-XXXX

# Run without persistent data and using an external configuration
docker run -it --privileged \
    -p 4242:4242 \
    -e RSW_LICENSE=$RSW_LICENSE \
    rstudio/rstudio-workbench:ubuntu2204
```

If possible, license key activation should be avoided in production environments in favor of using a license file due to 
the risk of leaking license activations when the container is not gracefully stopped. See the 
[caveats of product licensing in containers](#caveats-of-product-licensing-in-containers) section below for more 
details on license key issues.

### User Provisioning

By default, the container will create a test user, which you can control or disable with the environment
variables: `RSW_TESTUSER`, `RSW_TESTUSER_PASSWD`, `RSW_TESTUSER_UID`.

#### sssd / LDAP / Active Directory

If you have a directory (LDAP server, Active Directory, etc.) available to
provision users, `sssd` is installed in the container and enabled by default (
see `Process Management` below). In order to make use of it, you will need to
mount your own configuration file into `/etc/sssd/conf.d/`. For instance,

_sssd.conf_
```ini
[sssd]
config_file_version = 2
domains = LDAP

[domain/LDAP]
id_provider = ldap
auth_provider = ldap
chpass_provider = ldap
sudo_provider = ldap
# ... more configuration
```

Then:
```bash
# sssd is picky about file permissions
chmod 600 sssd.conf

docker run -it \
    -p 8787:8787 -p 5559:5559 \
    -v $PWD/data/rsp:/home \
    -v $PWD/server-pro/conf/:/etc/rstudio \
    -v $PWD/sssd.conf:/etc/sssd/conf.d/sssd.conf \
    -e RSW_LICENSE=$RSW_LICENSE \
    rstudio/rstudio-workbench:ubuntu2204
```

It is worth noting that you may also need to modify the PAM configuration files
in the container, if you are using PAM for custom authentication or session
behavior. See the [Posit Workbench guide](
https://docs.posit.co/ide/server-pro/admin/authenticating_users/authenticating_users.html) for
more information.

### Environment variables

| Variable               | Description                                                                                                  | Default   |
|------------------------|--------------------------------------------------------------------------------------------------------------|-----------|
| `RSW_TESTUSER`         | Test user to be created in the container, turn off with an empty value                                       | `rstudio` |
| `RSW_TESTUSER_PASSWD`  | Test user password                                                                                           | `rstudio` |
| `RSW_TESTUSER_UID`     | Test user UID                                                                                                | `10000`   |
| `RSW_LICENSE`          | License key for Posit Workbench, format should be: `XXXX-XXXX-XXXX-XXXX-XXXX-XXXX-XXXX`                      | None      |
| `RSW_LICENSE_SERVER`   | Floating license server, format should be: `my.url.com:port`                                                 | None      |
| `RSW_LAUNCHER`         | Whether or not to use launcher locally / start the launcher process                                          | true      |
| `RSW_LAUNCHER_TIMEOUT` | The timeout, in seconds, to wait for launcher to start listening on the expected port before failing startup | 30        |

### Ports

| Variable | Description                           |
|----------|---------------------------------------|
| `8787`   | Default HTTP Port for Posit Workbench |
| `5559`   | Port for Posit Launcher server        |

### Example usage:

```bash
# Replace with valid license
export RSW_LICENSE=XXXX-XXXX-XXXX-XXXX-XXXX-XXXX-XXXX

# Run without persistent data and using an external configuration
docker run -it \
    -p 8787:8787 -p 5559:5559 \
    -v $PWD/workbench/conf/:/etc/rstudio \
    -e RSW_LICENSE=$RSW_LICENSE \
    rstudio/rstudio-workbench:ubuntu2204

# Run with persistent data and using an external configuration
docker run -it \
    -p 8787:8787 -p 5559:5559 \
    -v $PWD/data/rsw:/home \
    -v $PWD/workbench/conf/:/etc/rstudio \
    -e RSW_LICENSE=$RSW_LICENSE \
    rstudio/rstudio-workbench:ubuntu2204
```

Open [http://localhost:8787](http://localhost:8787) to access Posit Workbench.
The default username and password are `rstudio`.

### Process Management

In order for Posit Workbench to function properly, several services need to
be accounted for. We run these services using
[`supervisord`](http://supervisord.org/). `supervisord` is an open source
process supervisor with an active community. It enables running multiple
services in the container, as well as exiting the container if _any_ of those
services exit.

> NOTE: generally speaking, running multiple services in a single container is an anti-pattern.
> However, we have implemented the below as a workaround until Posit Workbench can
> handle users and other processes in a more container-friendly fashion

Details on the various processes and their configuration is below:

- **Posit Workbench**: the main server process
  - this startup configuration is mounted at `/startup/base`

- **Posit Job Launcher**: enables launching Jupyter, JupyterLab, and VSCode
  sessions, as well as talking to job schedulers like Slurm and Kubernetes.
  - Optional and enabled by default
  - this startup configuration is mounted at `/startup/launcher`
  - to disable, mount an empty volume over `/startup/launcher`

- **sssd**: often used for user provisioning when connected to an LDAP
  directory or other user store.
  - Optional, and enabled by default, but with a "dummy" domain it does
    nothing.
  - To use this with your directory, mount required `.conf` files into
    `/etc/sssd/conf.d/` (more details in `User Provisioning`, above)
  - Startup configuration is installed at `/startup/user-provisioning/`
  - To disable entirely, mount an empty volume over
    `/startup/user-provisioning/`

- **custom**: Do you have a service that you need to run inside the container
  for user provisioning or otherwise?  Mount other configuration files into
  `/startup/custom`, and they will be started and managed by `supervisord` as
  well
  - NOTE: in many cases (i.e. Kubernetes) `initContainers` or `sidecar` containers are a better fit

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
  * `/var/lib/.local`
  * `/var/lib/.prof`
  * `/var/lib/rstudio-workbench`
* Floating License
  * `/var/lib/.TurboFloat`

Please note that the files created in these directories are hardware locked and non-transferable between hosts. Due to
the nature of the hardware fingerprinting algorithm, any low-level changes to the host or container can cause existing
license state files to invalidate. To avoid this problem, we advise that product containers are gracefully shutdown
and allowed to deactivate prior to changing any hardware or firmware on the host (e.g. upgrading a network card or
updating BIOS) or the container (e.g. changing the network driver used or the allocated number of CPU cores).

While preserving license state data *can* help avoid license leaks across restarts, it's not a guarantee. If you run
into issues with your license, please do not hesitate to [contact Posit support](https://support.posit.co/hc/en-us).

While neither of these solutions will eliminate the problem, they should help mitigate it. We are still investigating a
long-term solution.

# License

The license associated with the Posit Docker Products repository is located [in LICENSE.md](https://github.com/rstudio/rstudio-docker-products/blob/main/LICENSE.md).

As is the case with all container images, the images themselves also contain other software which may be under other
licenses (i.e. bash, linux, system libraries, etc., along with any other direct or indirect dependencies of the primary
software being contained).

It is an image user's responsibility to ensure that use of this image (and any of its dependent layers) complies with
all relevant licenses for the software contained in the image.
