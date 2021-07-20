# Floating license server

**WARNING**: DO NOT USE. These images are for testing only. Floating Licenses should not be used within docker containers unless an
RStudio employee has suggested you do so, since the docker container failing could require manual intervention to fix (
see the app referenced below). We provide these images only for development and testing purposes.

If you want to test floating licenses locally. You will need to do the following:

- Request a floating license key from support@rstudio.com
- Ask your Support / Customer Success representative to be sure that the floating license key works within a
  hypervisor (by default, they do not)

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
- [RStudio Connect](https://docs.rstudio.com/connect/admin/licensing/#floating-licenses)
- [RStudio Package Manager](https://docs.rstudio.com/rspm/admin/licensing/#licensing-floating)

If you run into trouble with your license, this app may be helpful to deactivate all instances of the license:
http://apps.rstudio.com/deactivate-license/

# Contributing

**WARNING**: DO NOT USE IN PRODUCTION

> Floating license servers should be stable and reliable. They often require
> manual intervention to restart, so you should avoid using them in a container

The paradigm used here has:
 - a single Dockerfile to build many images
 - a build arg for `PRODUCT` (one of `rsp`,`ssp`,`rspm`,`connect`,`rstudio`)
 - a build arg for `PORT` (to expose the port that you want... just for image
   reference later)
 - a dynamically mapped "default config file" based on `PRODUCT`
     - Note that this could easily be done with a `sed` command, since PORT is
       all that changes...
     - Further, this file is only read on service up, so we can honestly just
       map it in as a mount (no reason to embed in the image)

Check out the [compose file](docker-compose.yml) that builds / starts
these images, using an environment variable to provide the LICENSE variable.

## Options

| PRODUCT | PORT | LICENSE                 |
|---------|------|-------------------------|
| rsp     | 8989 | `RSP_FLOAT_LICENSE`     |
| connect | 8999 | `RSC_FLOAT_LICENSE`     |
| rspm    | 8969 | `RSPM_FLOAT_LICENSE`    |
| ssp     | 8979 | `SSP_FLOAT_LICENSE`     |
| rstudio | 9019 | `RSTUDIO_FLOAT_LICENSE` |

## More Resources

- [Floating License Server Downloads](https://www.rstudio.com/floating-license-servers/)
- [Documentation](https://support.rstudio.com/hc/en-us/articles/115011574507-Floating-Licenses)
