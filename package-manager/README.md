# RStudio Package Manager

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

```bash
# Replace with valid license
export RSPM_LICENSE=XXXX-XXXX-XXXX-XXXX-XXXX-XXXX-XXXX

# Run without persistent data and using default configuration
docker run -it --privileged \
    -p 4242:4242 \
    -e RSPM_LICENSE=$RSPM_LICENSE \
    rstudio/rstudio-package-manager:latest
```

Open [http://localhost:4242](http://localhost:4242) to access RStudio Package Manager UI.

For a more "real" deployment, continue reading!

#### Overview

Note that running the RStudio Package Manager Docker image requires the container to run using the `--privileged` flag
and a valid RStudio Package Manager license.

This container includes:

1. R 3.6.1
3. RStudio Package Manager

#### Configuration

RStudio Package Manager is configured via the`/etc/rstudio-pm/rstudio-pm.gcfg` file. You should mount this file as
a volume from the host machine. Changes will take effect when the container is restarted.

Be sure the config file has these fields:

- `Server.DataDir` set to `/data/`
- `HTTP.Listen`

See a complete example of that file at `pacakge-manager/rstudio-connect.gcfg`.

#### Persistent Data

In order to persist RSPM package data data between container restarts configure RSPM `Server.DataDir` option to `/data`
and share the `/data` directory
with a persistent volume in the host machine or your docker orchestration system.

#### Licensing

Using the RStudio Package Manager docker image requires to have a valid License. You can set the RSC license in three ways:

1. Setting the `RSPM_LICENSE` environment variable to a valid license key inside the container
2. Setting the `RSPM_LICENSE_SERVER` environment variable to a valid license server / port inside the container
3. Mounting a `/etc/rstudio-pm/license.lic` single file that contains a valid license for RStudio Package Manager

**NOTE:** the "offline activation process" is not supported by this image today. Offline installations will need
to explore using a license server, license file, or custom image with manual intervention.

#### Environment variables

| Variable | Description | Default |
|-----|---|---|
| `RSPM_LICENSE` | License key for RStudio Package Manager, format should be: `XXXX-XXXX-XXXX-XXXX-XXXX-XXXX-XXXX` | None |
| `RSPM_LICENSE_SERVER` | Floating license server, format should be: `my.url.com:port` | None |

#### Ports

| Variable | Description |
|-----|---|
| `4242` | Default HTTP Port for RStudio Package Manager |

#### Example usage

```bash
# Replace with valid license
export RSPM_LICENSE=XXXX-XXXX-XXXX-XXXX-XXXX-XXXX-XXXX

# Run without persistent data and using an external configuration
docker run -it --privileged \
    -p 4242:4242 \
    -v $PWD/package-manager/rstudio-pm.gcfg:/etc/rstudio-pm/rstudio-pm.gcfg \
    -e RSPM_LICENSE=$RSPM_LICENSE \
    rstudio/rstudio-package-manager:latest

# Run with persistent data and using an external configuration
docker run -it --privileged \
    -p 4242:4242 \
    -v $PWD/data/rspm:/data \
    -v $PWD/package-manager/rstudio-pm.gcfg:/etc/rstudio-pm/rstudio-pm.gcfg \
    -e RSPM_LICENSE=$RSPM_LICENSE \
    rstudio/rstudio-package-manager:latest
```

Open [http://localhost:4242](http://localhost:4242) to access RStudio Package Manager UI.

To create repositories you need to access the container directly and execute some commands.
To do this find the container ID for RSPM (using `docker ps`) and run:

```
docker exec -it {container-id} /bin/bash
```

Then please refer to the [RSPM guide](https://docs.rstudio.com/rspm/admin/) on how
to [create and manage](https://docs.rstudio.com/rspm/admin/getting-started/configuration/) your repositories. For
example to serve CRAN:

```
# Initiate a sync:
rspm sync --wait

# Create a repository:
rspm create repo --name=prod-cran --description='Access CRAN packages'

# Subscribe the repository to the cran source:
rspm subscribe --repo=prod-cran --source=cran
```
