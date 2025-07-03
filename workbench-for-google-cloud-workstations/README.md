# Quick reference

* Maintained by: [the Posit Docker team](https://github.com/rstudio/rstudio-docker-products)
* Where to get help: [our Github Issues page](https://github.com/rstudio/rstudio-docker-products/issues)
* RStudio Workbench image: [Docker Hub](https://hub.docker.com/r/rstudio/rstudio-workbench)
* RStudio r-session-complete image: [Docker Hub](https://hub.docker.com/r/rstudio/r-session-complete)
* Registry for this image: [Posit's Google Cloud Artifact Registry](https://console.cloud.google.com/artifacts/docker/posit-images/us-central1/cloud-workstations/workbench)

# What is RStudio Workbench?

Posit Workbench, formerly RStudio Workbench, is the preferred data analysis and integrated development experience for 
professional R users and data science teams who use R and Python. Posit Workbench enables the collaboration, 
centralized management, metrics, security, and commercial support that professional data science teams need to operate 
at scale.

Some of the functionality that Workbench provides is:

* The ability to develop in Workbench and Jupyter
* Load balancing
* Tutorial API
* Data connectivity and Posit Professional Drivers (formerly RStudio Professional Drivers)
* Collaboration and project sharing
* Scale with Kubernetes and SLURM
* Authentication, access, & security
* Run multiple concurrent R and Python sessions
* Remote execution with Launcher
* Auditing and monitoring
* Advanced R and Python session management

For more information on running RStudio Workbench in your organization please visit 
https://www.rstudio.com/products/workbench/.

# Notice for support

1. This image is still in early development. Some bugs may be present, and we may introduce **BREAKING** changes in 
   order to improve your user experience; as such we recommend:
   - Always read through the [NEWS](./NEWS.md) to understand the changes before updating or when encountering a bug.
   - Use the `latest` or "version" tags. Avoid using `daily` tagged images unless advised to by Posit staff.
1. Outdated images will be removed periodically from GCAR as product version updates are made. Please make plans to
   update at times, use the `latest` or version tag, or use your own build of the images.

# How to use this image

This image is designed for exclusive use with [Google Cloud Workstations](https://cloud.google.com/workstations). For
the generalized version of the Workbench image, go [here](https://hub.docker.com/r/rstudio/rstudio-workbench).

Using Google Cloud Workstations requires a Google Cloud Platform account. Click 
[here](https://console.cloud.google.com/workstations/overview) to navigate to the Cloud Workstations console. Posit
Workbench is provided in the default list of "Code editors on base images" when creating a workstation configuration.
Alternatively, administrators can use the "Custom container image" option to reference a specific tag from 
[Posit's public Google Cloud Artifact Registry](https://console.cloud.google.com/artifacts/docker/posit-images/us-central1/cloud-workstations/workbench).

For more information, please see 
[Cloud Workstation's official documentation](https://cloud.google.com/workstations/docs/develop-code-using-posit-workbench-rstudio).

## Overview

Note that running the RStudio Workbench Docker image requires a valid RStudio Workbench license for Google Cloud 
Workstations. Licenses can be obtained by emailing sales@posit.co.

This container includes:

1. Two versions of R
2. Two versions of Python
3. Quarto
4. Posit Workbench

### Product Licensing

The RStudio Workbench Docker image requires a valid license, which can be set using the `RSW_LICENSE` environment 
variable to a valid license key inside the container.

### Environment variables

| Variable               | Description                                                                                                  | Default |
|------------------------|--------------------------------------------------------------------------------------------------------------|---------|
| `RSW_LICENSE`          | License key for Posit Workbench, format should be: `XXXX-XXXX-XXXX-XXXX-XXXX-XXXX-XXXX`                      | None    |
| `RSW_LAUNCHER`         | Whether or not to use launcher locally / start the launcher process                                          | true    |
| `RSW_LAUNCHER_TIMEOUT` | The timeout, in seconds, to wait for launcher to start listening on the expected port before failing startup | 10      |

# License

The license associated with the Posit Docker Products repository is located [in LICENSE.md](https://github.com/rstudio/rstudio-docker-products/blob/main/LICENSE.md).

As is the case with all container images, the images themselves also contain other software which may be under other
licenses (i.e. bash, linux, system libraries, etc., along with any other direct or indirect dependencies of the primary
software being contained).

It is an image user's responsibility to ensure that use of this image (and any of its dependent layers) complies with
all relevant licenses for the software contained in the image._
