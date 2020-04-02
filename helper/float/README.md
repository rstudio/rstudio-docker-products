# Floating License Server

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
