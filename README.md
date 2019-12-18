# RStudio products docker stacks

Docker images for RStudio Professional Products

**Note:** Running any RStudio profesional products inside docker requires you to have a valid license for the product.
Also remember to deactivate the license before stopping the container or it will count as an active license,
look at the `startup.sh` scripts for an example on how to do this automatically.

## RStudio Server Pro

Note that running the RStudio Server Pro Docker image requires the container to run using the `--priviliged` flag and a valid RStudio Server Pro license.

This container includes:

1. R 3.6.1
2. Python 3.6.5
3. RStudio Server Pro 1.2.5019-6

#### Configuration

The configuration of RStudio Serve Pro is made on a set of file in the `/etc/rstudio` directory, mount this directory as volume with the host machine to change the configuration and restart the container for changes to take effect.

Be sure the config files have:

- `launcher.conf` and enable Local Launcher
- `rserver.conf` to connect to the Local Launcher
- `jupyter.conf` with `jupyter-exe` pointing to the Jupyter executable in the Docker image

See a complete example of that file at `server-pro/conf`.

#### Persistent Data

In order to persist RSP user files between container restarts please mount `/home` with a persistent volume in the host machine or your docker orchestration system.

#### Licensing

Using the RStudio Server Pro Docker image requires to have a valid License. You can set the RSP license to use this in two ways:

1. Setting the `RSP_LICENSE` environment variable to a valid license key
2. Mounting a `/etc/rstudio-server/license.lic` single file that contains a valid license for RStudio Server Pro

#### Users

By default the container will create a test user, that user can be controlled by the environment variables: `RSP_TESTUSER`, `RSP_TESTUSER_PASSWD`, `RSP_TESTUSER_UID`.

In order to use this container with a different user structure such as LDAP you need to extend the container to use a valid PAM configuration.
See the [RStudio Server Pro guide](https://docs.rstudio.com/ide/server-pro/authenticating-users.html) for more information.

#### Environment variables

| Variable | Description | Default |
|-----|---|---|
| `RSP_TESTUSER` | Test user to be created in the container, turn off with an empty value | `rstudio` |
| `RSP_TESTUSER_PASSWD` | Test user password | `rstudio` |
| `RSP_TESTUSER_UID` | Test user UID | `10000` |
| `RSP_LICENSE` | License key for RStudio Server Pro, format should be: `XXXX-XXXX-XXXX-XXXX-XXXX-XXXX-XXXX` | None |

#### Ports

| Variable | Description |
|-----|---|
| `8787` | Default HTTP Port for RStudio Connect |
| `5559` | Port for RStudio Launcher server |

#### Example usage:

```
# Replace with valid license
export RSP_LICENSE=XXXX-XXXX-XXXX-XXXX-XXXX-XXXX-XXXX

# Run without persistent data and default configuration
docker run --privileged -it \
    -p 8787:8787 -p 5559:5559 \
    -e RSP_LICENSE=$RSP_LICENSE \
    rstudio/server-pro:1.2.5019-6

# Run persistening data and external configuration
docker run --privileged -it \
    -p 8787:8787 -p 5559:5559 \
    -v $PWD/data/rsp:/home \
    -v $PWD/server-pro/conf/:/etc/rstudio \
    -e RSP_LICENSE=$RSP_LICENSE \
    rstudio/server-pro:1.2.5019-6
```

Open [http://localhost:3939](http://localhost:3939) to access RStudio Connect.
The default username and password are `rstudio`.

## RStudio Connect

This Docker container is built following the [RStudio Connect admin guide](https://docs.rstudio.com/connect/admin/index.html), please see [Server Guide/Docker](https://docs.rstudio.com/connect/admin/server-management.html#server-docker) for more details on the requirements and how to extend this image.

This container includes:

1. R 3.6.1
2. Python 3.6.5
3. RStudio Connect 1.7.4.1-7

Note that running the RStudio Connect Docker image requires the container to run using the `--priviliged` flag and a valid RStudio Connect license.

#### Configuration

The configuration of RStudio Connect is made on the `/etc/rstudio-connect/rstudio-connect.gcfg` file, mount this file as volume with an external file on the host machine to change the configuration and restart the container for changes to take effect.

Be sure the config file has this fields:

- `Server.DataDir` set to `/data/`
- `HTTP.Listen`
- `Python.Enabled` and `Python.Executable`

See a complete example of that file at `connect/rstudio-connect.gcfg`.

#### Persistent Data

In order to persist RSC metadata and app data between container restarts configure RSC `Server.DataDir` option to `/data` and share the `/data` directory
with a persistent volume in the host machine or your docker orchestration system.

#### Licensing

Using the RStudio Connect docker image requires to have a valid License. You can set the RSC license in two ways:

1. Setting the `RSC_LICENSE` environment variable to a valid license key
2. Mounting a `/etc/rstudio-connect/license.lic` single file that contains a valid license for RStudio Connect

#### Environment variables

| Variable | Description | Default |
|-----|---|---|
| `RSC_LICENSE` | License key for RStudio Connect, format should be: `XXXX-XXXX-XXXX-XXXX-XXXX-XXXX-XXXX` | None |

#### Ports

| Variable | Description |
|-----|---|
| `3939` | Default HTTP Port for RStudio Connect |

#### Example usage

```
# Replace with valid license
export RSC_LICENSE=XXXX-XXXX-XXXX-XXXX-XXXX-XXXX-XXXX

# Run without persistent data and default configuration
docker run -it --privileged \
    -p 3939:3939 \
    -e RSC_LICENSE=$RSC_LICENSE \
    rstudio/connect:1.7.8-7

# Run persistening data and external configuration
docker run -it --privileged \
    -p 3939:3939 \
    -v $PWD/data/rsc:/data \
    -v $PWD/connect/rstudio-connect.gcfg:/etc/rstudio-connect/rstudio-connect.gcfg \
    -e RSC_LICENSE=$RSC_LICENSE \
    rstudio/connect:1.7.8-7
```

Open [http://localhost:3939](http://localhost:3939) to access RStudio Connect.


## RStudio Package Manager

Note that running the RStudio Package Manager Docker image requires the container to run using the `--priviliged` flag and a valid RStudio Package Manager license.

This container includes:

1. R 3.6.1
3. RStudio Package Manager 1.1.0.1-17

#### Configuration

The configuration of RStudio Package Manager is made on the `/etc/rstudio-pm/rstudio-pm.gcfg` file, mount this file as volume with an external file on the host machine to change the configuration and restart the container for changes to take effect.

Be sure the config file has this fields:

- `Server.DataDir` set to `/data/`
- `HTTP.Listen`

See a complete example of that file at `pacakge-manager/rstudio-connect.gcfg`.

#### Persistent Data

In order to persist RSPM package data data between container restarts configure RSPM `Server.DataDir` option to `/data` and share the `/data` directory
with a persistent volume in the host machine or your docker orchestration system.

#### Licensing

Using the RStudio Package Manager docker image requires to have a valid License. You can set the RSC license in two ways:

1. Setting the `RSPM_LICENSE` environment variable to a valid license key
2. Mounting a `/etc/rstudio-pm/license.lic` single file that contains a valid license for RStudio Package Manager

#### Environment variables

| Variable | Description | Default |
|-----|---|---|
| `RSPM_LICENSE` | License key for RStudio Package Manager, format should be: `XXXX-XXXX-XXXX-XXXX-XXXX-XXXX-XXXX` | None |

#### Ports

| Variable | Description |
|-----|---|
| `4242` | Default HTTP Port for RStudio Package Manager |

#### Example usage

```
# Replace with valid license
export RSPM_LICENSE=XXXX-XXXX-XXXX-XXXX-XXXX-XXXX-XXXX

# Run without persistent data and default configuration
docker run -it --privileged \
    -p 4242:4242 \
    -e RSPM_LICENSE=$RSPM_LICENSE \
    rstudio/package-manager:1.1.0.1-17

# Run persistening data and external configuration
docker run -it --privileged \
    -p 4242:4242 \
    -v $PWD/data/rspm:/data \
    -v $PWD/package-manager/rstudio-pm.gcfg:/etc/rstudio-pm/rstudio-pm.gcfg \
    -e RSPM_LICENSE=$RSPM_LICENSE \
    rstudio/package-manager:1.1.0.1-17
```

Open [http://localhost:4242](http://localhost:4242) to access RStudio Package Manager UI.

To create repositories you need to access the container directly and execute some commands.
To do this find the container ID for RSPM (using `docker ps`) and run:

```
docker exec -it <container-id> /bin/bash
```

Then please refer to the [RSPM guide](https://docs.rstudio.com/rspm/admin/) on how to [create and manage](https://docs.rstudio.com/rspm/admin/quickstarts.html) your repositories. For example to serve CRAN:

```
# Initiate a sync:
rspm sync --wait

# Create a repository:
rspm create repo --name=prod-cran --description='Access CRAN packages'

# Subscribe the repository to the cran source:
rspm subscribe --repo=prod-cran --source=cran
```

## Docker Compose

We provide a `docker-compose.yml` that could help to spin up default configurations for RStudio products.

If you are using this locally you need to setup some hostnames to point to `localhost` in order for some integrations to work fine in your browser.
In your `/etc/hosts` add one line:

```
127.0.0.1 rstudio-server-pro rstudio-connect rstudio-pm
```

```
# Replace this with valid licenses
export RSP_LICENSE=XXXX-XXXX-XXXX-XXXX-XXXX-XXXX-XXXX
export RSC_LICENSE=XXXX-XXXX-XXXX-XXXX-XXXX-XXXX-XXXX
export RSPM_LICENSE=XXXX-XXXX-XXXX-XXXX-XXXX-XXXX-XXXX

docker-compose up
```
