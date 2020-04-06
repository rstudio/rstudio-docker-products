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
3. RStudio Server Pro

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
2. Setting the `RSP_LICENSE_SERVER` environment variable to a valid license server / port
3. Mounting a `/etc/rstudio-server/license.lic` single file that contains a valid license for RStudio Server Pro

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

# Run without persistent data and default configuration
docker run --privileged -it \
    -p 8787:8787 -p 5559:5559 \
    -e RSP_LICENSE=$RSP_LICENSE \
    rstudio/rstudio-server-pro:latest

# Run with persisting data and external configuration
docker run --privileged -it \
    -p 8787:8787 -p 5559:5559 \
    -v $PWD/data/rsp:/home \
    -v $PWD/server-pro/conf/:/etc/rstudio \
    -e RSP_LICENSE=$RSP_LICENSE \
    rstudio/rstudio-server-pro:latest
```

Open [http://localhost:8787](http://localhost:8787) to access RStudio Server Pro.
The default username and password are `rstudio`.

## RStudio Connect

This Docker container is built following the [RStudio Connect admin guide](https://docs.rstudio.com/connect/admin/index.html), please see [Server Guide/Docker](https://docs.rstudio.com/connect/admin/server-management.html#server-docker) for more details on the requirements and how to extend this image.

This container includes:

1. R 3.6.1
2. Python 3.6.5
3. RStudio Connect

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
2. Setting the `RSC_LICENSE_SERVER` environment variable to a valid license server / port
3. Mounting a `/etc/rstudio-connect/license.lic` single file that contains a valid license for RStudio Connect

#### Environment variables

| Variable | Description | Default |
|-----|---|---|
| `RSC_LICENSE` | License key for RStudio Connect, format should be: `XXXX-XXXX-XXXX-XXXX-XXXX-XXXX-XXXX` | None |
| `RSC_LICENSE_SERVER` | Floating license server, format should be: `my.url.com:port` | None |

#### Ports

| Variable | Description |
|-----|---|
| `3939` | Default HTTP Port for RStudio Connect |

#### Example usage

```bash
# Replace with valid license
export RSC_LICENSE=XXXX-XXXX-XXXX-XXXX-XXXX-XXXX-XXXX

# Run without persistent data and default configuration
docker run -it --privileged \
    -p 3939:3939 \
    -e RSC_LICENSE=$RSC_LICENSE \
    rstudio/rstudio-connect:latest

# Run with persisting data and external configuration
docker run -it --privileged \
    -p 3939:3939 \
    -v $PWD/data/rsc:/data \
    -v $PWD/connect/rstudio-connect.gcfg:/etc/rstudio-connect/rstudio-connect.gcfg \
    -e RSC_LICENSE=$RSC_LICENSE \
    rstudio/rstudio-connect:latest
```

Open [http://localhost:3939](http://localhost:3939) to access RStudio Connect.


## RStudio Package Manager

Note that running the RStudio Package Manager Docker image requires the container to run using the `--priviliged` flag and a valid RStudio Package Manager license.

This container includes:

1. R 3.6.1
3. RStudio Package Manager

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
2. Setting the `RSPM_LICENSE_SERVER` environment variable to a valid license server / port
3. Mounting a `/etc/rstudio-pm/license.lic` single file that contains a valid license for RStudio Package Manager

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

# Run without persistent data and default configuration
docker run -it --privileged \
    -p 4242:4242 \
    -e RSPM_LICENSE=$RSPM_LICENSE \
    rstudio/rstudio-package-manager:latest

# Run with persisting data and external configuration
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

Then please refer to the [RSPM guide](https://docs.rstudio.com/rspm/admin/) on how to [create and manage](https://docs.rstudio.com/rspm/admin/quickstarts.html) your repositories. For example to serve CRAN:

```
# Initiate a sync:
rspm sync --wait

# Create a repository:
rspm create repo --name=prod-cran --description='Access CRAN packages'

# Subscribe the repository to the cran source:
rspm subscribe --repo=prod-cran --source=cran
```

## RStudio Team

We provide a `docker-compose.yml` that could help to spin up default configurations for RStudio Team (all RStudio products together).

If you are using this locally you need to setup some hostnames to point to `localhost` in order for some integrations to work fine in your browser.
In your `/etc/hosts` add one line:

```
127.0.0.1 rstudio-server-pro rstudio-connect rstudio-pm
```

```bash
# Replace this with valid licenses
export RSP_LICENSE=XXXX-XXXX-XXXX-XXXX-XXXX-XXXX-XXXX
export RSC_LICENSE=XXXX-XXXX-XXXX-XXXX-XXXX-XXXX-XXXX
export RSPM_LICENSE=XXXX-XXXX-XXXX-XXXX-XXXX-XXXX-XXXX

docker-compose up
```

## Privileged Containers

Notice that each example above uses the `--privileged` flag. Each RStudio
Professional product uses the `--privileged` flag for user and code isolation
and security. Each product differs in the exact reasons why, but we would love
to hear from you if this is concerning in your infrastructure.

If you have feedback on any of our professional products, please always feel
free to reach out [on RStudio
Community](https://community.rstudio.com/c/r-admin), to your Customer Success
representative, or to sales@rstudio.com.

## Floating license server

**WARNING**: Floating Licenses should not be used within docker containers in a
production context, since the docker container failing could require manual
intervention to fix (see the app below). We provide these images only for
development and testing.

If you want to test floating licenses locally. You will need to do the following:

- Request a floating license key (these are different from normal license keys)
- Ensure that the floating license key works within a hypervisor (by default, they do not)

Then run:

```bash
# Replace this with valid licenses
export RSP_FLOAT_LICENSE=XXXX-XXXX-XXXX-XXXX-XXXX-XXXX-XXXX
export RSC_FLOAT_LICENSE=XXXX-XXXX-XXXX-XXXX-XXXX-XXXX-XXXX
export RSPM_FLOAT_LICENSE=XXXX-XXXX-XXXX-XXXX-XXXX-XXXX-XXXX

make run-floating-lic-server
```

This will build and run 3 containers that are accessible in the `rstudio-docker-products` network at these hostnames:

- RStudio Server Pro: `rsp-float-lic:8989`
- RStudio Connect: `rsc-float-lic:8999`
- RStudio Package Manager: `rspm-float-lic:8969`

After on a new terminal that you can run any product docker containers, for example:

```bash
export RSP_LICENSE_SERVER=rsp-float-lic:8989
export RSC_LICENSE_SERVER=rsc-float-lic:8999
export RSPM_LICENSE_SERVER=rspm-float-lic:8969

# RStudio Server Pro
docker run --privileged -it \
    -p 8787:8787 -p 5559:5559 \
    -v $PWD/data/rsp:/home \
    -v $PWD/server-pro/conf/:/etc/rstudio \
    -e RSP_LICENSE_SERVER=$RSP_LICENSE_SERVER \
    --network rstudio-docker-products \
    rstudio/rstudio-server-pro:1.2.5033-1

# RStudio Connect
docker run -it --privileged \
    -p 3939:3939 \
    -v $PWD/data/rsc:/data \
    -v $PWD/connect/rstudio-connect.gcfg:/etc/rstudio-connect/rstudio-connect.gcfg \
    -e RSC_LICENSE_SERVER=$RSC_LICENSE_SERVER \
    --network rstudio-docker-products \
    rstudio/rstudio-connect:1.8.0.3-19

# RStudio Package Manager
docker run -it --privileged \
    -p 4242:4242 \
    -v $PWD/data/rspm:/data \
    -v $PWD/package-manager/rstudio-pm-float.gcfg:/etc/rstudio-pm/rstudio-pm.gcfg \
    -e RSPM_LICENSE_SERVER=$RSPM_LICENSE_SERVER \
    --network rstudio-docker-products \
    rstudio/rstudio-package-manager:latest
```

**Note:** You need to configure the products (config files) to use remote license, please look at the corresponding admin guides.

- [RStudio Server Pro](https://docs.rstudio.com/ide/server-pro/license-management.html#floating-licensing)
- [RStudio Connect](https://docs.rstudio.com/connect/admin/license-management.html#floating-licenses)
- [RStudio Package Manager](https://docs.rstudio.com/rspm/admin/licensing.html#licensing-floating)

If you run into trouble with your license, this app may be helpful to deactivate all instances of the license:
http://apps.rstudio.com/deactivate-license/
