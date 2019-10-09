# RStudio products docker stacks

Docker images for RStudio Professional Products

Running any RStudio profesional products inside docker requires you to have a valid license for the product.

## RStudio Server Pro

Running RStudio Server Pro requires the container to run using the `--priviliged` flag.

**Mount paths:**

In order to persist user files between container restarts please mount `/home` with a persistent volume in the host machine or your docker orchestration system.

- `/etc/rstudio`: Directory for all RStudio Server Pro configuration files, see example at `server-pro/config`
- `/home/`: Directory for user home files
- `/etc/rstudio-server/license.lic`: (Optional) Single file that contains a valid license for RStudio Server Pro

**Environment variables:**

| Variable | Description | Default |
|-----|---|---|
| `RSP_LICENSE` | License key for RStudio Server Pro, format should be: `XXXX-XXXX-XXXX-XXXX-XXXX-XXXX-XXXX` | None |
| `RSP_TESTUSER` | Test user to be created in the container, disable with empty value | `rstudio` |
| `RSP_TESTUSER_PASSWD` | Test user password | `rstudio` |
| `RSP_TESTUSER_UID` | Test user UID | `rstudio` |

**Example usage:**

```
# Replace with valid license
export RSP_LICENSE=XXXX-XXXX-XXXX-XXXX-XXXX-XXXX-XXXX

docker run --privileged -it -p 8787:8787 -p 5559:5559 -v $PWD/server-pro/conf/:/etc/rstudio -e RSP_LICENSE=$RSP_LICENSE rstudio/server-pro:1.2.5001-3
```

## RStudio Connect

Running RStudio Connect requires the container to run using the `--priviliged` flag.

**Mount paths:**

In order to persist RSC metadata and app data between container restarts please share `/var/lib/rstudio-connect`
with a persistent volume in the host machine or your docker orchestration system.

- `/etc/rstudio-connect/rstudio-connect.gcfg`: RStudio Connect config file. See example at `connect/rstudio-connect.gcfg`
- `/var/lib/rstudio-connect`: Directory for all RStudio Connect application files
- `/etc/rstudio-connect/license.lic`: (Optional) Single file that contains a valid license for RStudio Connect

**Environment variables:**

| Variable | Description | Default |
|-----|---|---|
| `RSC_LICENSE` | License key for RStudio Connect, format should be: `XXXX-XXXX-XXXX-XXXX-XXXX-XXXX-XXXX` | None |

**Example usage:**

```
# Replace with valid license
export RSC_LICENSE=XXXX-XXXX-XXXX-XXXX-XXXX-XXXX-XXXX

docker run -it --privileged -p 3939:3939 -v $PWD/data/rsc:/var/lib/rstudio-connect -v $PWD/connect/rstudio-connect.gcfg:/etc/rstudio-connect/rstudio-connect.gcfg -e RSC_LICENSE=$RSC_LICENSE rstudio/connect:1.7.4.1-7
```
