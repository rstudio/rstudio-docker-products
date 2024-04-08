### Variable definitions ###
variable CONNECT_VERSION {
    default = "2024.02.0"
}

variable PACKAGE_MANAGER_VERSION {
    default = "2023.12.0-13"
}

variable WORKBENCH_VERSION {
    default = "2023.12.1+402.pro1"
}

variable DRIVERS_VERSION {
    default = "2024.03.0"
}

variable DEFAULT_QUARTO_VERSION {
    default = "1.4.553"
}

function workbench_version_clean {
    params = []
    result = split("+", WORKBENCH_VERSION)[0]
}

function get_os_alt_name {
    params = [os]
    result = os == "ubuntu2204" ? "jammy" : os
}

function get_drivers_version {
    params = [os]
    result = os == "centos7" ? "${DRIVERS_VERSION}-1" : DRIVERS_VERSION
}

function get_centos_tags {
    params = [os, product, product_version]
    result = [
        "ghcr.io/rstudio/${product}:${os}",
        "ghcr.io/rstudio/${product}:${os}-${product_version}",
        "docker.io/rstudio/${product}:${os}",
        "docker.io/rstudio/${product}:${os}-${product_version}",
    ]
}

function get_ubuntu_tags {
    params = [os, product, product_version]
    result = [
        "ghcr.io/rstudio/${product}:${os}",
        "ghcr.io/rstudio/${product}:${get_os_alt_name(os)}",
        "ghcr.io/rstudio/${product}:${os}-${product_version}",
        "ghcr.io/rstudio/${product}:${get_os_alt_name(os)}-${product_version}",
        "docker.io/rstudio/${product}:${os}",
        "docker.io/rstudio/${product}:${get_os_alt_name(os)}",
        "docker.io/rstudio/${product}:${os}-${product_version}",
        "docker.io/rstudio/${product}:${get_os_alt_name(os)}-${product_version}",
    ]
}

# FIXME: There's an obnoxious amount of hardcoding here due to restrictions with what bake can actually interpret from HCL.
function get_tags {
    params = [os, product, product_version]
    result = os == "ubuntu2204" ? get_ubuntu_tags(os, product, product_version) : get_centos_tags(os, product, product_version)
}

### Build matrices ###

variable BASE_BUILD_MATRIX {
    default = {
        builds = [
            {os = "centos7", r_primary = "4.2.0", r_alternate = "3.6.2", py_primary = "3.9.5", py_alternate = "3.8.10"},
            {os = "centos7", r_primary = "4.2.3", r_alternate = "4.1.3", py_primary = "3.9.14", py_alternate = "3.8.15"},
            {os = "ubuntu2204", r_primary = "4.2.0", r_alternate = "3.6.2", py_primary = "3.9.5", py_alternate = "3.8.10"},
            {os = "ubuntu2204", r_primary = "4.2.3", r_alternate = "4.1.3", py_primary = "3.9.14", py_alternate = "3.8.15"},
            {os = "ubuntu2204", r_primary = "4.2.3", r_alternate = "4.1.3", py_primary = "3.9.17", py_alternate = "3.8.17"},
            {os = "ubuntu2204", r_primary = "4.2.3", r_alternate = "4.1.3", py_primary = "3.12.1", py_alternate = "3.11.7"},
        ]
    }
}

variable PRO_BUILD_MATRIX {
    default = BASE_BUILD_MATRIX
}

variable PACKAGE_MANAGER_BUILD_MATRIX {
    default = {
        builds = [
            {os = "ubuntu2204", r_primary = "4.2.3", r_alternate = "4.1.3", py_primary = "3.12.1", py_alternate = "3.11.7"},
        ]
    }
}

variable CONNECT_BUILD_MATRIX {
    default = {
        builds = [
            {os = "ubuntu2204", r_primary = "4.2.3", r_alternate = "4.1.3", py_primary = "3.9.17", py_alternate = "3.8.17"},
        ]
    }
}

variable CONNECT_CONTENT_INIT_BUILD_MATRIX {
    default = {
        builds = [
            {os = "ubuntu2204"},
        ]
    }
}

variable R_SESSION_COMPLETE_BUILD_MATRIX {
    default = {
        builds = [
            {os = "centos7", r_primary = "4.2.3", r_alternate = "4.1.3", py_primary = "3.9.14", py_alternate = "3.8.15"},
            {os = "ubuntu2204", r_primary = "4.2.3", r_alternate = "4.1.3", py_primary = "3.9.14", py_alternate = "3.8.15"},
        ]
    }
}

variable WORKBENCH_BUILD_MATRIX {
    default = {
        builds = [
            {os = "ubuntu2204", r_primary = "4.2.3", r_alternate = "4.1.3", py_primary = "3.9.14", py_alternate = "3.8.15"},
        ]
    }
}

variable WORKBENCH_GOOGLE_CLOUD_WORKSTATION_BUILD_MATRIX {
    default = {
        builds = [
            {os = "ubuntu2004", r_primary = "4.2.3", r_alternate = "4.1.3", py_primary = "3.11.7", py_alternate = "3.10.13"},
        ]
    }
}

variable WORKBENCH_MICROSOFT_AZURE_ML_BUILD_MATRIX {
    default = {
        builds = [
            {os = "ubuntu2204", r_primary = "4.2.3", r_alternate = "4.1.3", py_primary = "3.9.14", py_alternate = "3.8.15"},
        ]
    }
}

### Group definitions ###
group "default" {
    targets = [
        "product-base",
        "product-base-pro",
        "connect",
        "connect-content-init",
        "package-manager",
        "r-session-complete",
        "workbench",
    ]
}

group "build" {
    targets = [
        "product-base",
        "product-base-pro",
        "connect",
        "connect-content-init",
        "package-manager",
        "r-session-complete",
        "workbench",
    ]
}

group "build-test" {
    targets = [
        "product-base",
        "product-base-pro",
        "connect",
        "connect-content-init",
        "package-manager",
        "r-session-complete",
        "workbench",
        "test-product-base",
        "test-product-base-pro",
        # "test-connect",  # FIXME: This target requires a privileged environment which bake cannot provide
        "test-connect-content-init",
        "test-package-manager",
        "test-r-session-complete",
        "test-workbench",
        "test-workbench-for-google-cloud-workstations",
        "test-workbench-for-microsoft-azure-ml",
    ]
}

group "test" {
    targets = [
        "test-product-base",
        "test-product-base-pro",
        # "test-connect",  # FIXME: This target requires a privileged environment which bake cannot provide
        "test-connect-content-init",
        "test-package-manager",
        "test-r-session-complete",
        "test-workbench",
        "test-workbench-for-google-cloud-workstations",
        "test-workbench-for-microsoft-azure-ml",
    ]
}

group "base-images" {
    targets = [
        "product-base",
        "test-product-base",
        "product-base-pro",
        "test-product-base-pro",
    ]
}

group "package-manager-images" {
    targets = [
        "package-manager",
        "test-package-manager",
    ]
}

group "connect-images" {
    targets = [
        "connect",
        # "test-connect",  # FIXME: This target requires a privileged environment which bake cannot provide
    ]
}

group "connect-content-init-images" {
    targets = [
        "connect-content-init",
        "test-connect-content-init",
    ]
}

group "r-session-complete-images" {
    targets = [
        "r-session-complete",
        "test-r-session-complete",
    ]
}

group "workbench-images" {
    targets = [
        "workbench",
        "test-workbench",
    ]
}

group "wgcw-images" {
    targets = [
        "workbench-for-google-cloud-workstations",
        "test-workbench-for-google-cloud-workstations",
    ]
}

group "waml-images" {
    targets = [
        "build-workbench-for-microsoft-azure-ml",
        "scan-workbench-for-microsoft-azure-ml",
        "test-workbench-for-microsoft-azure-ml",
        "workbench-for-microsoft-azure-ml",
    ]
}

### Base Image targets ###
target "base" {
    labels = {
        "maintainer" = "Posit Docker <docker@posit.co>"
    }
    output = ["type=image"]
}

target "product-base" {
    inherits = ["base"]
    target = "build"

    name = "product-base-${builds.os}-r${replace(builds.r_primary, ".", "-")}_${replace(builds.r_alternate, ".", "-")}-py${replace(builds.py_primary, ".", "-")}_${replace(builds.py_alternate, ".", "-")}"
    tags = [
        "ghcr.io/rstudio/product-base:${builds.os}-r${builds.r_primary}_${builds.r_alternate}-py${builds.py_primary}_${builds.py_alternate}",
        "docker.io/rstudio/product-base:${builds.os}-r${builds.r_primary}_${builds.r_alternate}-py${builds.py_primary}_${builds.py_alternate}",
    ]
    
    dockerfile = "Dockerfile.${builds.os}"
    context = "product/base"    

    matrix = BASE_BUILD_MATRIX
    args = {
        R_VERSION = builds.r_primary
        R_VERSION_ALT = builds.r_alternate
        PYTHON_VERSION = builds.py_primary
        PYTHON_VERSION_ALT = builds.py_alternate
        TINI_VERSION = "0.19.0"
        QUARTO_VERSION = "1.3.340"
    }    
}

target "test-product-base" {
    inherits = ["product-base-${builds.os}-r${replace(builds.r_primary, ".", "-")}_${replace(builds.r_alternate, ".", "-")}-py${replace(builds.py_primary, ".", "-")}_${replace(builds.py_alternate, ".", "-")}"]
    target = "test"

    name = "test-product-base-${builds.os}-r${replace(builds.r_primary, ".", "-")}_${replace(builds.r_alternate, ".", "-")}-py${replace(builds.py_primary, ".", "-")}_${replace(builds.py_alternate, ".", "-")}"
    tags = []

    contexts = {
        build = "target:product-base-${builds.os}-r${replace(builds.r_primary, ".", "-")}_${replace(builds.r_alternate, ".", "-")}-py${replace(builds.py_primary, ".", "-")}_${replace(builds.py_alternate, ".", "-")}"
    }

    matrix = BASE_BUILD_MATRIX
}

target "product-base-pro" {
    inherits = ["base"]
    target = "build"

    name = "product-base-pro-${builds.os}-r${replace(builds.r_primary, ".", "-")}_${replace(builds.r_alternate, ".", "-")}-py${replace(builds.py_primary, ".", "-")}_${replace(builds.py_alternate, ".", "-")}"
    tags = [
        "ghcr.io/rstudio/product-base-pro:${builds.os}-r${builds.r_primary}_${builds.r_alternate}-py${builds.py_primary}_${builds.py_alternate}",
        "docker.io/rstudio/product-base-pro:${builds.os}-r${builds.r_primary}_${builds.r_alternate}-py${builds.py_primary}_${builds.py_alternate}",
    ]

    dockerfile = "Dockerfile.${builds.os}"   
    context = "product/pro"
    contexts = {
        product-base = "target:product-base-${builds.os}-r${replace(builds.r_primary, ".", "-")}_${replace(builds.r_alternate, ".", "-")}-py${replace(builds.py_primary, ".", "-")}_${replace(builds.py_alternate, ".", "-")}"
    }

    matrix = PRO_BUILD_MATRIX
    args = {
        R_VERSION = builds.r_primary
        R_VERSION_ALT = builds.r_alternate
        PYTHON_VERSION = builds.py_primary
        PYTHON_VERSION_ALT = builds.py_alternate
        DRIVERS_VERSION = get_drivers_version(builds.os)
        TINI_VERSION = "0.19.0"
        QUARTO_VERSION = "1.3.340"
    }    
}

target "test-product-base-pro" {
    inherits = ["product-base-pro-${builds.os}-r${replace(builds.r_primary, ".", "-")}_${replace(builds.r_alternate, ".", "-")}-py${replace(builds.py_primary, ".", "-")}_${replace(builds.py_alternate, ".", "-")}"]
    target = "test"

    name = "test-product-base-pro-${builds.os}-r${replace(builds.r_primary, ".", "-")}_${replace(builds.r_alternate, ".", "-")}-py${replace(builds.py_primary, ".", "-")}_${replace(builds.py_alternate, ".", "-")}"
    tags = []

    contexts = {
        build = "target:product-base-pro-${builds.os}-r${replace(builds.r_primary, ".", "-")}_${replace(builds.r_alternate, ".", "-")}-py${replace(builds.py_primary, ".", "-")}_${replace(builds.py_alternate, ".", "-")}"
    }

    matrix = PRO_BUILD_MATRIX
}

### Package Manager targets ###
target "package-manager" {
    inherits = ["base"]
    target = "build"

    name = "package-manager-${builds.os}-${replace(PACKAGE_MANAGER_VERSION, ".", "-")}"
    tags = get_tags(builds.os, "package-manager", PACKAGE_MANAGER_VERSION)

    dockerfile = "Dockerfile.${builds.os}"
    context = "package-manager"
    contexts = {
        product-base = "target:product-base-${builds.os}-r${replace(builds.r_primary, ".", "-")}_${replace(builds.r_alternate, ".", "-")}-py${replace(builds.py_primary, ".", "-")}_${replace(builds.py_alternate, ".", "-")}"
    }

    matrix = PACKAGE_MANAGER_BUILD_MATRIX
    args = {
        R_VERSION = builds.r_primary
        R_VERSION_ALT = builds.r_alternate
        PYTHON_VERSION = builds.py_primary
        PYTHON_VERSION_ALT = builds.py_alternate
        RSPM_VERSION = PACKAGE_MANAGER_VERSION
    }
}

target "test-package-manager" {
    inherits = ["package-manager-${builds.os}-${replace(PACKAGE_MANAGER_VERSION, ".", "-")}"]
    target = "test"

    name = "test-package-manager-${builds.os}-${replace(PACKAGE_MANAGER_VERSION, ".", "-")}"
    tags = []

    contexts = {
        build = "target:package-manager-${builds.os}-${replace(PACKAGE_MANAGER_VERSION, ".", "-")}"
    }

    matrix = PACKAGE_MANAGER_BUILD_MATRIX
}

### Connect targets ###
target "connect" {
    inherits = ["base"]
    target = "build"

    name = "connect-${builds.os}-${replace(CONNECT_VERSION, ".", "-")}"
    tags = get_tags(builds.os, "rstudio-connect", CONNECT_VERSION)

    # We output Connect to OCI so it can be pulled in for testing later on.
    output = [
        "type=image",
        "type=oci,tar=false,dest=./.out/connect-${builds.os}-${replace(CONNECT_VERSION, ".", "-")}"
    ]

    dockerfile = "Dockerfile.${builds.os}"
    context = "connect"
    contexts = {
        product-base-pro = "target:product-base-pro-${builds.os}-r${replace(builds.r_primary, ".", "-")}_${replace(builds.r_alternate, ".", "-")}-py${replace(builds.py_primary, ".", "-")}_${replace(builds.py_alternate, ".", "-")}"
    }

    matrix = CONNECT_BUILD_MATRIX
    args = {
        R_VERSION = builds.r_primary
        R_VERSION_ALT = builds.r_alternate
        PYTHON_VERSION = builds.py_primary
        PYTHON_VERSION_ALT = builds.py_alternate
        RSC_VERSION = CONNECT_VERSION
    }
}

# FIXME: This target requires a privileged environment which bake cannot provide
target "test-connect" {
    inherits = ["connect-${builds.os}-${replace(CONNECT_VERSION, ".", "-")}"]
    target = "test"

    name = "test-connect-${builds.os}-${replace(CONNECT_VERSION, ".", "-")}"
    tags = []

    contexts = {
        build = "target:connect-${builds.os}-${replace(CONNECT_VERSION, ".", "-")}"
    }

    matrix = CONNECT_BUILD_MATRIX
}

target "connect-content-init" {
    inherits = ["base"]
    target = "build"

    name = "connect-content-init-${builds.os}-${replace(CONNECT_VERSION, ".", "-")}"
    tags = get_tags(builds.os, "rstudio-connect-content-init", CONNECT_VERSION)

    dockerfile = "Dockerfile.${builds.os}"
    context = "connect-content-init"

    matrix = CONNECT_CONTENT_INIT_BUILD_MATRIX

    args = {
        RSC_VERSION = CONNECT_VERSION
    }
}

target "test-connect-content-init" {
    inherits = ["connect-content-init-${builds.os}-${replace(CONNECT_VERSION, ".", "-")}"]
    target = "test"

    name = "test-connect-content-init-${builds.os}-${replace(CONNECT_VERSION, ".", "-")}"
    tags = []

    contexts = {
        build = "target:connect-content-init-${builds.os}-${replace(CONNECT_VERSION, ".", "-")}"
    }

    matrix = CONNECT_CONTENT_INIT_BUILD_MATRIX
}

### Workbench targets ###
target "r-session-complete" {
    inherits = ["base"]
    target = "build"

    name = "r-session-complete-${builds.os}-${replace(workbench_version_clean(), ".", "-")}"
    tags = get_tags(builds.os, "r-session-complete", workbench_version_clean())

    dockerfile = "Dockerfile.${builds.os}"
    context = "r-session-complete"
    contexts = {
        product-base-pro = "target:product-base-pro-${builds.os}-r${replace(builds.r_primary, ".", "-")}_${replace(builds.r_alternate, ".", "-")}-py${replace(builds.py_primary, ".", "-")}_${replace(builds.py_alternate, ".", "-")}"
    }

    matrix = R_SESSION_COMPLETE_BUILD_MATRIX
    args = {
        R_VERSION = builds.r_primary
        R_VERSION_ALT = builds.r_alternate
        PYTHON_VERSION = builds.py_primary
        PYTHON_VERSION_ALT = builds.py_alternate
        JUPYTERLAB_VERSION = "3.6.5"
        RSW_VERSION = WORKBENCH_VERSION
        RSW_NAME = builds.os == "centos7" ? "rstudio-workbench-rhel" : "rstudio-workbench"
        RSW_DOWNLOAD_URL = builds.os == "centos7" ? "https://s3.amazonaws.com/rstudio-ide-build/server/centos7/x86_64" : "https://download2.rstudio.org/server/jammy/amd64"
    }
}

target "test-r-session-complete" {
    inherits = ["r-session-complete-${builds.os}-${replace(workbench_version_clean(), ".", "-")}"]
    target = "test"

    name = "test-r-session-complete-${builds.os}-${replace(workbench_version_clean(), ".", "-")}"
    tags = []

    contexts = {
        build = "target:r-session-complete-${builds.os}-${replace(workbench_version_clean(), ".", "-")}"
    }

    matrix = R_SESSION_COMPLETE_BUILD_MATRIX
}

target "workbench" {
    inherits = ["base"]

    name = "workbench-${builds.os}-${replace(workbench_version_clean(), ".", "-")}"
    tags = get_tags(builds.os, "rstudio-workbench", workbench_version_clean())

    dockerfile = "Dockerfile.${builds.os}"
    context = "workbench"
    contexts = {
        product-base-pro = "target:product-base-pro-${builds.os}-r${replace(builds.r_primary, ".", "-")}_${replace(builds.r_alternate, ".", "-")}-py${replace(builds.py_primary, ".", "-")}_${replace(builds.py_alternate, ".", "-")}"
    }

    matrix = WORKBENCH_BUILD_MATRIX
    args = {
        R_VERSION = builds.r_primary
        R_VERSION_ALT = builds.r_alternate
        PYTHON_VERSION = builds.py_primary
        PYTHON_VERSION_ALT = builds.py_alternate
        PYTHON_VERSION_JUPYTER = builds.py_alternate
        RSW_VERSION = WORKBENCH_VERSION
        RSW_NAME = "rstudio-workbench"
        RSW_DOWNLOAD_URL = "https://download2.rstudio.org/server/jammy/amd64"
    }        
}

target "test-workbench" {
    inherits = ["workbench-${builds.os}-${replace(workbench_version_clean(), ".", "-")}"]

    name = "test-workbench-${builds.os}-${replace(workbench_version_clean(), ".", "-")}"
    tags = []

    contexts = {
        build = "target:workbench-${builds.os}-${replace(workbench_version_clean(), ".", "-")}"
    }

    matrix = WORKBENCH_BUILD_MATRIX
}

### Workbench for Google Cloud Workstations targets ###
target "workbench-for-google-cloud-workstations" {
    inherits = ["base"]

    name = "workbench-for-google-cloud-workstation-${builds.os}-${replace(workbench_version_clean(), ".", "-")}"
    tags = [
        "us-central1-docker.pkg.dev/posit-images/cloud-workstations/workbench:latest",
        "us-central1-docker.pkg.dev/posit-images/cloud-workstations/workbench:${workbench_version_clean()}",
        "us-docker.pkg.dev/posit-images/cloud-workstations/workbench:latest",
        "us-docker.pkg.dev/posit-images/cloud-workstations/workbench:${workbench_version_clean()}",
        "europe-docker.pkg.dev/posit-images/cloud-workstations/workbench:latest",
        "europe-docker.pkg.dev/posit-images/cloud-workstations/workbench:${workbench_version_clean()}",
        "asia-docker.pkg.dev/posit-images/cloud-workstations/workbench:latest",
        "asia-docker.pkg.dev/posit-images/cloud-workstations/workbench:${workbench_version_clean()}",
    ]    

    dockerfile = "Dockerfile.${builds.os}"
    context = "workbench-for-google-cloud-workstations"

    matrix = WORKBENCH_GOOGLE_CLOUD_WORKSTATION_BUILD_MATRIX
    args = {
        R_VERSION = builds.r_primary
        R_VERSION_ALT = builds.r_alternate
        PYTHON_VERSION = builds.py_primary
        PYTHON_VERSION_ALT = builds.py_alternate
        PYTHON_VERSION_JUPYTER = builds.py_alternate
        JUPYTERLAB_VERSION = "3.6.5"
        QUARTO_VERSION = DEFAULT_QUARTO_VERSION
        DRIVERS_VERSION = get_drivers_version(builds.os)
        RSW_VERSION = WORKBENCH_VERSION
        RSW_NAME = "rstudio-workbench"
        RSW_DOWNLOAD_URL = "https://download2.rstudio.org/server/focal/amd64"
    } 
}

target "test-workbench-for-google-cloud-workstations" {
    inherits = ["workbench-for-google-cloud-workstation-${builds.os}-${replace(workbench_version_clean(), ".", "-")}"]

    name = "test-workbench-for-google-cloud-workstation-${builds.os}-${replace(workbench_version_clean(), ".", "-")}"
    tags = []

    contexts = {
        build = "target:workbench-for-google-cloud-workstation-${builds.os}-${replace(workbench_version_clean(), ".", "-")}"
    }

    matrix = WORKBENCH_GOOGLE_CLOUD_WORKSTATION_BUILD_MATRIX
}

### Workbench for Microsoft Azure ML targets ###

target "build-workbench-for-microsoft-azure-ml" {
    inherits = ["base"]
    target = "build"

    name = "build-workbench-for-microsoft-azure-ml-${builds.os}-${replace(workbench_version_clean(), ".", "-")}"

    dockerfile = "Dockerfile.${builds.os}"
    context = "workbench-for-microsoft-azure-ml"
    contexts = {
        product-base-pro = "target:product-base-pro-${builds.os}-r${replace(builds.r_primary, ".", "-")}_${replace(builds.r_alternate, ".", "-")}-py${replace(builds.py_primary, ".", "-")}_${replace(builds.py_alternate, ".", "-")}"
    }

    matrix = WORKBENCH_MICROSOFT_AZURE_ML_BUILD_MATRIX
    args = {
        R_VERSION = builds.r_primary
        R_VERSION_ALT = builds.r_alternate
        PYTHON_VERSION = builds.py_primary
        PYTHON_VERSION_ALT = builds.py_alternate
        PYTHON_VERSION_JUPYTER = builds.py_alternate
        JUPYTERLAB_VERSION = "3.6.5"
        RSW_VERSION = WORKBENCH_VERSION
        RSW_NAME = "rstudio-workbench"
        RSW_DOWNLOAD_URL = "https://download2.rstudio.org/server/jammy/amd64"
    } 
}

target "scan-workbench-for-microsoft-azure-ml" {
    inherits = ["build-workbench-for-microsoft-azure-ml-${builds.os}-${replace(workbench_version_clean(), ".", "-")}"]
    target = "clamav"

    name = "scan-workbench-for-microsoft-azure-ml-${builds.os}-${replace(workbench_version_clean(), ".", "-")}"

    contexts = {
        build = "target:build-workbench-for-microsoft-azure-ml-${builds.os}-${replace(workbench_version_clean(), ".", "-")}"
    }

    matrix = WORKBENCH_MICROSOFT_AZURE_ML_BUILD_MATRIX
}

target "test-workbench-for-microsoft-azure-ml" {
    inherits = ["build-workbench-for-microsoft-azure-ml-${builds.os}-${replace(workbench_version_clean(), ".", "-")}"]
    target = "test"

    name = "test-workbench-for-microsoft-azure-ml-${builds.os}-${replace(workbench_version_clean(), ".", "-")}"

    contexts = {
        build = "target:build-workbench-for-microsoft-azure-ml-${builds.os}-${replace(workbench_version_clean(), ".", "-")}"
    }

    matrix = WORKBENCH_MICROSOFT_AZURE_ML_BUILD_MATRIX
}

target "workbench-for-microsoft-azure-ml" {
    inherits = ["build-workbench-for-microsoft-azure-ml-${builds.os}-${replace(workbench_version_clean(), ".", "-")}"]
    target = "final"

    name = "workbench-for-microsoft-azure-ml-${builds.os}-${replace(workbench_version_clean(), ".", "-")}"
    tags = get_tags(builds.os, "rstudio-workbench-for-microsoft-azure-ml", workbench_version_clean())

    contexts = {
        build = "target:build-workbench-for-microsoft-azure-ml-${builds.os}-${replace(workbench_version_clean(), ".", "-")}"
        clamav = "target:scan-workbench-for-microsoft-azure-ml-${builds.os}-${replace(workbench_version_clean(), ".", "-")}"
    }

    matrix = WORKBENCH_MICROSOFT_AZURE_ML_BUILD_MATRIX
}