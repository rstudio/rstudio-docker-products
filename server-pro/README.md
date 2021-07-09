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

Open http://localhost:8787 to access RStudio Server Pro. The default username and password are rstudio.

For a more "real" deployment, continue reading!

#### Overview

Note that running the RStudio Server Pro Docker image requires the container to run using the `--privileged` flag and a
valid RStudio Server Pro license.

This container includes:

1. R 3.6.1
2. Python 3.6.5
3. RStudio Server Pro

#### Configuration

The configuration of RStudio Server Pro is made on a set of file in the `/etc/rstudio` directory. Mount this directory as
volume with the host machine to change the configuration and restart the container for changes to take effect.

Be sure the config files have:

- `launcher.conf` and enable Local Launcher
- `rserver.conf` to connect to the Local Launcher
- `jupyter.conf` with `jupyter-exe` pointing to the Jupyter executable in the Docker image

See a complete example of that file at `server-pro/conf`.

#### Persistent Data

In order to persist RSP user files between container restarts please mount `/home` with a persistent volume in the host
machine or your docker orchestration system.

#### Licensing

Using the RStudio Server Pro Docker image requires to have a valid License. You can set the RSP license to use this in
one three ways:

1. Setting the `RSP_LICENSE` environment variable to a valid license key
2. Setting the `RSP_LICENSE_SERVER` environment variable to a valid license server / port
3. Mounting a `/etc/rstudio-server/license.lic` single file that contains a valid license for RStudio Server Pro

**NOTE:** the "offline activation process" is not supported by this image today. Offline installations will need
to explore using a license server, license file, or custom image with manual intervention.

#### Users

By default the container will create a test user, that user can be controlled by the environment
variables: `RSP_TESTUSER`, `RSP_TESTUSER_PASSWD`, `RSP_TESTUSER_UID`.

In order to use this container with a different user structure such as LDAP you need to extend the container to use a
valid PAM configuration. See
the [RStudio Server Pro guide](https://docs.rstudio.com/ide/server-pro/authenticating-users.html) for more information.

#### Environment variables

| Variable | Description | Default |
|-----|---|---|
| `RSP_TESTUSER` | Test user to be created in the container, turn off with an empty value | `rstudio` |
| `RSP_TESTUSER_PASSWD` | Test user password | `rstudio` |
| `RSP_TESTUSER_UID` | Test user UID | `10000` |
| `RSP_LICENSE` | License key for RStudio Server Pro, format should be: `XXXX-XXXX-XXXX-XXXX-XXXX-XXXX-XXXX` | None |
| `RSP_LICENSE_SERVER` | Floating license server, format should be: `my.url.com:port` | None |
| `RSP_LAUNCHER` | Whether or not to use launcher locally / start the launcher process | true |
| `RSP_LAUNCHER_TIMEOUT` | The timeout, in seconds, to wait for launcher to startup before proceeding | 10 |

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
