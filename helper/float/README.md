# Floating License Server

**WARNING**: DO NOT USE IN PRODUCTION

> Floating license servers should be stable and reliable. They often require
> manual intervention to restart, so you should avoid using them in a contianer

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

| PRODUCT | PORT | LICENSE               |
|---------|------|-----------------------|
| rsp     | 8989 | RSP\_FLOAT\_LICENSE     |
| connect | 8999 | RSC\_FLOAT\_LICENSE |
| rspm    | 8969 | RSPM\_FLOAT\_LICENSE    |
| ssp     | 8979 | SSP\_FLOAT\_LICENSE     |
| rstudio | 9019 | RSTUDIO\_FLOAT\_LICENSE |

## More Resources

- [Floating License Server Downloads](https://www.rstudio.com/floating-license-servers/)
- [Documentation](https://support.rstudio.com/hc/en-us/articles/115011574507-Floating-Licenses)
