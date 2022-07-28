# RStudio Pro Products Docker Images

> **WARNING: pwnkit vulernability response**
>
> Bionic-based versions of the r-session-complete docker image are affected by the [PwnKit vulnerability](https://ubuntu.com/security/CVE-2021-4034).
> If you are using this image in your RStudio Workbench Kubernetes environment, you should update it immediately. [See the linked support article for details](https://support.rstudio.com/hc/en-us/articles/4420538249495)
>
> Other images are not affected

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
   
# Images

### Professional Products

- [RStudio Workbench](./workbench/)
- [RStudio Connect](./connect/)
- [RStudio Package Manager](./package-manager/)

### Supporting Images

- RStudio Workbench Session Images (requires the launcher)
    - [R Session Complete](./r-session-complete/)

### Preview Images

*IMPORTANT:* Do not use these images. They are in preparation for a future release

- RStudio Connect Session Images (requires the launcher)
    - [Content Base Image](./content-base/)
    - [Content Init Container](./connect-content-init/)

# RStudio Team

We provide a `docker-compose.yml` that could help to spin up default configurations for RStudio Team (all RStudio
products together).

If you are using this locally you need to setup some hostnames to point to `localhost` in order for some integrations to
work fine in your browser. In your `/etc/hosts` add one line:

```
127.0.0.1 rstudio-workbench rstudio-connect rstudio-pm
```

```bash
# Replace this with valid licenses
export RSW_LICENSE=XXXX-XXXX-XXXX-XXXX-XXXX-XXXX-XXXX
export RSC_LICENSE=XXXX-XXXX-XXXX-XXXX-XXXX-XXXX-XXXX
export RSPM_LICENSE=XXXX-XXXX-XXXX-XXXX-XXXX-XXXX-XXXX

docker-compose up
```

# Privileged Containers

As of July 2022, only the RStudio Connect container uses the `--privileged` flag for user and code isolation and 
security and all other images can be run unprivileged. Please see 
[RStudio Professional Product Root & Privileged Requirements](https://support.rstudio.com/hc/en-us/articles/1500005369282)
for more information.

If you have feedback on any of our professional products, please always feel free to reach
out [on RStudio Community](https://community.rstudio.com/c/r-admin), to your Customer Success representative, or to
sales@rstudio.com.

# Instructions for building

After you have cloned [rstudio-docker-products](https://github.com/rstudio/rstudio-docker-products), you can create your
own containers fairly simply with the provided Makefile.

To build RStudio Workbench:
```
make workbench
```
To build RStudio Connect:
```
make connect
```
To build RStudio Package Manager:
```
make package-manager
```

You can alter what exactly is built by changing `workbench/Dockerfile`, `connect/Dockerfile`,
and `package-manager/Dockerfile`.

You can then run what you've built to test out with the `run-` commands. For instance, to run the workbench container
you have built:
```
make run-workbench
```

Note you must have a license in place, and all of the other instructions in separate sections are still relevant.

If you have created an image you want to use yourself, you can push to your own image repository system. The images are
named `rstudio-workbench`, `rstudio-connect`, and `rstudio-package-manager`.

# Licensing

The license associated with the RStudio Docker Products repository is
located [in LICENSE.md](https://github.com/rstudio/rstudio-docker-products/blob/main/LICENSE.md).

As is the case with all container images, the images themselves also contain other software which may be under other
licenses (i.e. bash, linux, system libraries, etc., along with any other direct or indirect dependencies of the primary
software being contained).

It is an image user's responsibility to ensure that use of this image (and any of its dependent layers) complies with
all relevant licenses for the software contained in the image.
