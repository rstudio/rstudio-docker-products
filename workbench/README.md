# RStudio Workbench

Docker images for RStudio Professional Products

**IMPORTANT:** There are a few things you need to know before using these images:

1. These images are provided as a convenience to RStudio customers and are not formally supported by RStudio. If you
   have questions about these images, you can ask them in the issues in the repository or to your support
   representative, who will route them appropriately.
1. Outdated images will be removed periodically from DockerHub as product version updates are made. Please make plans to
   update at times or use your own build of the images.
1. These images are meant as a starting point for your needs. Consider creating a fork of this repo, where you can
   continue to merge in changes we make while having your own security scanning, base OS in use, or other custom
   changes. We
   provide [instructions for building](https://github.com/rstudio/rstudio-docker-products#instructions-for-building) for
   these cases.

### Simple Example

To verify basic functionality as a first step:

```
# Replace with valid license
export RSW_LICENSE=XXXX-XXXX-XXXX-XXXX-XXXX-XXXX-XXXX

# Run without persistent data using default configuration
docker run -it \
    -p 8787:8787 \
    -e RSW_LICENSE=$RSW_LICENSE \
    rstudio/rstudio-workbench:latest
    
# Alternatively, the above can be ran using a single just command
just RSW_LICENSE=XXXX-XXXX-XXXX-XXXX-XXXX-XXXX-XXXX run
```

Open http://localhost:8787 to access RStudio Workbench. The default username and password are `rstudio`.

For a more "real" deployment, continue reading!

### Overview

Note that running the RStudio Workbench Docker image requires a valid RStudio Workbench license.

This container includes:

1. R 3.6
2. R 4.1
3. Python 3.8.10
4. Python 3.9.5
5. RStudio Workbench

### Configuration

RStudio Workbench is configured via config files in the `/etc/rstudio` directory. Mount this directory as
a volume from the host machine. Changes will take effect when the container is restarted.

You can review possible RStudio Workbench configuration [in the documentation](https://docs.rstudio.com/ide/workbench/).

See a complete example of server configuration at `workbench/conf`.

### Persistent Data

In order to persist user files between container restarts please mount the `/home` directory from a persistent volume on the host
machine or your docker orchestration system.

### Licensing

The RStudio Workbench Docker image requires a valid license, which can be set in three ways:

1. Setting the `RSW_LICENSE` environment variable to a valid license key inside the container
2. Setting the `RSW_LICENSE_SERVER` environment variable to a valid license server / port inside the container
3. Mounting a `/etc/rstudio-server/license.lic` single file that contains a valid license for RStudio Workbench

**NOTE:** the "offline activation process" is not supported by this image today. Offline installations will need
to explore using a license server, license file, or custom image with manual intervention.

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
    -e RSP_LICENSE=$RSP_LICENSE \
    rstudio/rstudio-workbench:latest
```

It is worth noting that you may also need to modify the PAM configuration files
in the container, if you are using PAM for custom authentication or session
behavior. See the [RStudio Workbench
guide](https://docs.rstudio.com/ide/server-pro/authenticating-users.html) for
more information.

### Environment variables

| Variable | Description | Default |
|-----|---|---|
| `RSW_TESTUSER` | Test user to be created in the container, turn off with an empty value | `rstudio` |
| `RSW_TESTUSER_PASSWD` | Test user password | `rstudio` |
| `RSW_TESTUSER_UID` | Test user UID | `10000` |
| `RSW_LICENSE` | License key for RStudio Workbench, format should be: `XXXX-XXXX-XXXX-XXXX-XXXX-XXXX-XXXX` | None |
| `RSW_LICENSE_SERVER` | Floating license server, format should be: `my.url.com:port` | None |
| `RSW_LAUNCHER` | Whether or not to use launcher locally / start the launcher process | true |
| `RSW_LAUNCHER_TIMEOUT` | The timeout, in seconds, to wait for launcher to start listening on the expected port before failing startup | 10 |

### Ports

| Variable | Description |
|-----|---|
| `8787` | Default HTTP Port for RStudio Connect |
| `5559` | Port for RStudio Launcher server |

### Example usage:

```bash
# Replace with valid license
export RSW_LICENSE=XXXX-XXXX-XXXX-XXXX-XXXX-XXXX-XXXX

# Run without persistent data and using an external configuration
docker run -it \
    -p 8787:8787 -p 5559:5559 \
    -v $PWD/workbench/conf/:/etc/rstudio \
    -e RSW_LICENSE=$RSW_LICENSE \
    rstudio/rstudio-workbench:latest

# Run with persistent data and using an external configuration
docker run -it \
    -p 8787:8787 -p 5559:5559 \
    -v $PWD/data/rsw:/home \
    -v $PWD/workbench/conf/:/etc/rstudio \
    -e RSW_LICENSE=$RSW_LICENSE \
    rstudio/rstudio-workbench:latest
```

Open [http://localhost:8787](http://localhost:8787) to access RStudio Workbench.
The default username and password are `rstudio`.

### Process Management

In order for RStudio Workbench to function properly, several services need to
be accounted for. We run these services using
[`supervisord`](http://supervisord.org/). `supervisord` is an open source
process supervisor with an active community. It enables running multiple
services in the container, as well as exiting the container if _any_ of those
services exit.

> NOTE: generally speaking, running multiple services in a single container is an anti-pattern.
> However, we have implemented the below as a workaround until RStudio Workbench can
> handle users and other processes in a more container-friendly fashion

Details on the various processes and their configuration is below:

- **RStudio Workbench**: the main server process
  - this startup configuration is mounted at `/startup/base`

- **RStudio Job Launcher**: enables launching Jupyter, JupyterLab, and VSCode
  sessions, as well as talking to job schedulers like Slurm and Kubernetes.
  - Optional and enabled by default
  - this startup configuration is mounted at `/startup/launcher`
  - to disable, mount an empty volume over `/startup/launcher`  

- **sssd**: often used for user provisioning when connected to an LDAP
  directory or other user store. 
  - Optional, and enabled by default, but with a "dummy" domain so it does
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

# Licensing

The license associated with the RStudio Docker Products repository is located [in LICENSE.md](https://github.com/rstudio/rstudio-docker-products/blob/main/LICENSE.md).

As is the case with all container images, the images themselves also contain other software which may be under other
licenses (i.e. bash, linux, system libraries, etc., along with any other direct or indirect dependencies of the primary
software being contained).

It is an image user's responsibility to ensure that use of this image (and any of its dependent layers) complies with
all relevant licenses for the software contained in the image.
