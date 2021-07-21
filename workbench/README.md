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

#### Simple Example

To verify basic functionality as a first step:

```
# Replace with valid license
export RSP_LICENSE=XXXX-XXXX-XXXX-XXXX-XXXX-XXXX-XXXX

# Run without persistent data using default configuration
docker run --privileged -it \
    -p 8787:8787 \
    -e RSP_LICENSE=$RSP_LICENSE \
    rstudio/rstudio-workbench:latest
```

Open http://localhost:8787 to access RStudio Workbench. The default username and password are _rstudio_.

For a more "real" deployment, continue reading!

#### Overview

Note that running the RStudio Workbench Docker image requires the container to run using the `--privileged` flag and a
valid RStudio Workbench license.

This container includes:

1. R 3.6.1
2. Python 3.6.5
3. RStudio Workbench

#### Configuration

RStudio Workbench is configured via config files in the in the `/etc/rstudio` directory. Mount this directory as
a volume from the host machine. Changes will take effect when the container is restarted.

You can review possible RStudio Workbench configuration [in the documentation](https://docs.rstudio.com/ide/server-pro/).

See a complete example of server configuration at `server-pro/conf`.

#### Persistent Data

In order to persist user files between container restarts please mount the `/home` directory from a persistent volume on the host
machine or your docker orchestration system.

#### Licensing

The RStudio Workbench Docker image requires a valid license, which can be set in three ways:

1. Setting the `RSP_LICENSE` environment variable to a valid license key inside the container
2. Setting the `RSP_LICENSE_SERVER` environment variable to a valid license server / port inside the container
3. Mounting a `/etc/rstudio-server/license.lic` single file that contains a valid license for RStudio Server Pro

**NOTE:** the "offline activation process" is not supported by this image today. Offline installations will need
to explore using a license server, license file, or custom image with manual intervention.

#### Users

By default, the container will create a test user, which you can control or disable with the environment
variables: `RSP_TESTUSER`, `RSP_TESTUSER_PASSWD`, `RSP_TESTUSER_UID`.

This container needs to be extended with a valid PAM configuration if you want to use it with an external user directory
such as LDAP/AD. See the [RStudio Workbench guide](https://docs.rstudio.com/ide/server-pro/authenticating-users.html)
for more information.

#### Environment variables

| Variable | Description | Default |
|-----|---|---|
| `RSP_TESTUSER` | Test user to be created in the container, turn off with an empty value | `rstudio` |
| `RSP_TESTUSER_PASSWD` | Test user password | `rstudio` |
| `RSP_TESTUSER_UID` | Test user UID | `10000` |
| `RSP_LICENSE` | License key for RStudio Server Pro, format should be: `XXXX-XXXX-XXXX-XXXX-XXXX-XXXX-XXXX` | None |
| `RSP_LICENSE_SERVER` | Floating license server, format should be: `my.url.com:port` | None |
| `RSP_LAUNCHER` | Whether or not to use launcher locally / start the launcher process | true |
| `RSP_LAUNCHER_TIMEOUT` | The timeout, in seconds, to wait for launcher to start listening on the expected port before failing startup | 10 |

#### Ports

| Variable | Description |
|-----|---|
| `8787` | Default HTTP Port for RStudio Connect |
| `5559` | Port for RStudio Launcher server |

#### Example usage:

```bash
# Replace with valid license
export RSP_LICENSE=XXXX-XXXX-XXXX-XXXX-XXXX-XXXX-XXXX

# Run without persistent data and using an external configuration
docker run --privileged -it \
    -p 8787:8787 -p 5559:5559 \
    -v $PWD/server-pro/conf/:/etc/rstudio \
    -e RSP_LICENSE=$RSP_LICENSE \
    rstudio/rstudio-workbench:latest

# Run with persistent data and using an external configuration
docker run --privileged -it \
    -p 8787:8787 -p 5559:5559 \
    -v $PWD/data/rsp:/home \
    -v $PWD/server-pro/conf/:/etc/rstudio \
    -e RSP_LICENSE=$RSP_LICENSE \
    rstudio/rstudio-workbench:latest
```

Open [http://localhost:8787](http://localhost:8787) to access RStudio Server Pro.
The default username and password are `rstudio`.

# Licensing

The license associated with the RStudio Docker Products repository is located [in LICENSE.md](https://github.com/rstudio/rstudio-docker-products/blob/main/LICENSE.md).

As is the case with all container images, the images themselves also contain other software which may be under other
licenses (i.e. bash, linux, system libraries, etc., along with any other direct or indirect dependencies of the primary
software being contained).

It is an image user's responsibility to ensure that use of this image (and any of its dependent layers) complies with
all relevant licenses for the software contained in the image.
