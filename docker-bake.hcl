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

function get_drivers_version {
    params = [os]
    result = os == "centos7" ? "${DRIVERS_VERSION}-1" : DRIVERS_VERSION
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
            {os = "ubuntu2004", r_primary = "4.2.3", r_alternate = "4.1.3", py_primary = "3.12.1", py_alternate = "3.11.7"},
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
    output = ["type=cacheonly"]
}

target "product-base" {
    inherits = ["base"]
    target = "build"

    name = "product-base-${builds.os}-r${replace(builds.r_primary, ".", "-")}_${replace(builds.r_alternate, ".", "-")}-py${replace(builds.py_primary, ".", "-")}_${replace(builds.py_alternate, ".", "-")}"
    tags = [
        "ghcr.io/rstudio/product-base:${builds.os}-r${builds.r_primary}_${builds.r_alternate}-py${builds.py_primary}_${builds.py_alternate}",
        "docker.io/rstudio/product-base:${builds.os}-r${builds.r_primary}_${builds.r_alternate}-py${builds.py_primary}_${builds.py_alternate}",
    ]
    output = [
        "type=cacheonly",
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
    output = [
        "type=cacheonly",
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

    name = "package-manager-${builds.os}-r${replace(builds.r_primary, ".", "-")}_${replace(builds.r_alternate, ".", "-")}-py${replace(builds.py_primary, ".", "-")}_${replace(builds.py_alternate, ".", "-")}"
    tags = [
        "ghcr.io/rstudio/rstudio-package-manager:${builds.os}-r${builds.r_primary}_${builds.r_alternate}-py${builds.py_primary}_${builds.py_alternate}",
        "docker.io/rstudio/rstudio-package-manager:${builds.os}-r${builds.r_primary}_${builds.r_alternate}-py${builds.py_primary}_${builds.py_alternate}",
    ]    

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
    inherits = ["package-manager-${builds.os}-r${replace(builds.r_primary, ".", "-")}_${replace(builds.r_alternate, ".", "-")}-py${replace(builds.py_primary, ".", "-")}_${replace(builds.py_alternate, ".", "-")}"]
    target = "test"

    name = "test-package-manager-${builds.os}-r${replace(builds.r_primary, ".", "-")}_${replace(builds.r_alternate, ".", "-")}-py${replace(builds.py_primary, ".", "-")}_${replace(builds.py_alternate, ".", "-")}"
    tags = []

    contexts = {
        build = "target:package-manager-${builds.os}-r${replace(builds.r_primary, ".", "-")}_${replace(builds.r_alternate, ".", "-")}-py${replace(builds.py_primary, ".", "-")}_${replace(builds.py_alternate, ".", "-")}"
    }

    matrix = PACKAGE_MANAGER_BUILD_MATRIX
}

### Connect targets ###
target "connect" {
    inherits = ["base"]
    target = "build"

    name = "connect-${builds.os}-r${replace(builds.r_primary, ".", "-")}_${replace(builds.r_alternate, ".", "-")}-py${replace(builds.py_primary, ".", "-")}_${replace(builds.py_alternate, ".", "-")}"
    tags = [
        "ghcr.io/rstudio/rstudio-connect:${builds.os}-r${builds.r_primary}_${builds.r_alternate}-py${builds.py_primary}_${builds.py_alternate}",
        "docker.io/rstudio/rstudio-connect:${builds.os}-r${builds.r_primary}_${builds.r_alternate}-py${builds.py_primary}_${builds.py_alternate}",
    ]
    # We output Connect to OCI so it can be pulled in for testing later on.
    output = [
        "type=cacheonly",
        "type=oci,tar=false,dest=./.out/connect-${builds.os}-r${replace(builds.r_primary, ".", "-")}_${replace(builds.r_alternate, ".", "-")}-py${replace(builds.py_primary, ".", "-")}_${replace(builds.py_alternate, ".", "-")}"
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
    inherits = ["connect-${builds.os}-r${replace(builds.r_primary, ".", "-")}_${replace(builds.r_alternate, ".", "-")}-py${replace(builds.py_primary, ".", "-")}_${replace(builds.py_alternate, ".", "-")}"]
    target = "test"

    name = "test-connect-${builds.os}-r${replace(builds.r_primary, ".", "-")}_${replace(builds.r_alternate, ".", "-")}-py${replace(builds.py_primary, ".", "-")}_${replace(builds.py_alternate, ".", "-")}"
    tags = []

    contexts = {
        build = "target:connect-${builds.os}-r${replace(builds.r_primary, ".", "-")}_${replace(builds.r_alternate, ".", "-")}-py${replace(builds.py_primary, ".", "-")}_${replace(builds.py_alternate, ".", "-")}"
    }

    matrix = CONNECT_BUILD_MATRIX
}

target "connect-content-init" {
    inherits = ["base"]
    target = "build"

    name = "connect-content-init-${builds.os}-${replace(CONNECT_VERSION, ".", "-")}"
    tags = [
        "ghcr.io/rstudio/product-connect-content-init:${builds.os}",
        "ghcr.io/rstudio/product-connect-content-init:${builds.os}-${CONNECT_VERSION}",
        "docker.io/rstudio/product-connect-content-init:${builds.os}",
        "docker.io/rstudio/product-connect-content-init:${builds.os}-${CONNECT_VERSION}",
    ]    

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

    name = "r-session-complete-${builds.os}-r${replace(builds.r_primary, ".", "-")}_${replace(builds.r_alternate, ".", "-")}-py${replace(builds.py_primary, ".", "-")}_${replace(builds.py_alternate, ".", "-")}"
    tags = [
        "ghcr.io/rstudio/product-r-session-complete:${builds.os}-r${builds.r_primary}_${builds.r_alternate}-py${builds.py_primary}_${builds.py_alternate}",
        "docker.io/rstudio/product-r-session-complete:${builds.os}-r${builds.r_primary}_${builds.r_alternate}-py${builds.py_primary}_${builds.py_alternate}",
    ]    

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
    inherits = ["r-session-complete-${builds.os}-r${replace(builds.r_primary, ".", "-")}_${replace(builds.r_alternate, ".", "-")}-py${replace(builds.py_primary, ".", "-")}_${replace(builds.py_alternate, ".", "-")}"]
    target = "test"

    name = "test-r-session-complete-${builds.os}-r${replace(builds.r_primary, ".", "-")}_${replace(builds.r_alternate, ".", "-")}-py${replace(builds.py_primary, ".", "-")}_${replace(builds.py_alternate, ".", "-")}"
    tags = []

    contexts = {
        build = "target:r-session-complete-${builds.os}-r${replace(builds.r_primary, ".", "-")}_${replace(builds.r_alternate, ".", "-")}-py${replace(builds.py_primary, ".", "-")}_${replace(builds.py_alternate, ".", "-")}"
    }

    matrix = R_SESSION_COMPLETE_BUILD_MATRIX
}

target "workbench" {
    inherits = ["base"]

    name = "workbench-${builds.os}-r${replace(builds.r_primary, ".", "-")}_${replace(builds.r_alternate, ".", "-")}-py${replace(builds.py_primary, ".", "-")}_${replace(builds.py_alternate, ".", "-")}"
    tags = [
        "ghcr.io/rstudio/product-workbench:${builds.os}-r${builds.r_primary}_${builds.r_alternate}-py${builds.py_primary}_${builds.py_alternate}",
        "docker.io/rstudio/product-workbench:${builds.os}-r${builds.r_primary}_${builds.r_alternate}-py${builds.py_primary}_${builds.py_alternate}",
    ]    

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
    inherits = ["workbench-${builds.os}-r${replace(builds.r_primary, ".", "-")}_${replace(builds.r_alternate, ".", "-")}-py${replace(builds.py_primary, ".", "-")}_${replace(builds.py_alternate, ".", "-")}"]

    name = "test-workbench-${builds.os}-r${replace(builds.r_primary, ".", "-")}_${replace(builds.r_alternate, ".", "-")}-py${replace(builds.py_primary, ".", "-")}_${replace(builds.py_alternate, ".", "-")}"
    tags = []

    contexts = {
        build = "target:workbench-${builds.os}-r${replace(builds.r_primary, ".", "-")}_${replace(builds.r_alternate, ".", "-")}-py${replace(builds.py_primary, ".", "-")}_${replace(builds.py_alternate, ".", "-")}"
    }

    matrix = WORKBENCH_BUILD_MATRIX
}

### Workbench for Google Cloud Workstations targets ###
target "workbench-for-google-cloud-workstations" {
    inherits = ["base"]

    name = "workbench-for-google-cloud-workstation-${builds.os}-r${replace(builds.r_primary, ".", "-")}_${replace(builds.r_alternate, ".", "-")}-py${replace(builds.py_primary, ".", "-")}_${replace(builds.py_alternate, ".", "-")}"
    tags = [
        "ghcr.io/rstudio/workbench-for-google-cloud-workstation:${builds.os}-r${builds.r_primary}_${builds.r_alternate}-py${builds.py_primary}_${builds.py_alternate}",
        "docker.io/rstudio/workbench-for-google-cloud-workstation:${builds.os}-r${builds.r_primary}_${builds.r_alternate}-py${builds.py_primary}_${builds.py_alternate}",
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
        QUARTO_VERSION = "1.4.550"
        DRIVERS_VERSION = get_drivers_version(builds.os)
        RSW_VERSION = WORKBENCH_VERSION
        RSW_NAME = "rstudio-workbench"
        RSW_DOWNLOAD_URL = "https://download2.rstudio.org/server/focal/amd64"
    } 
}

target "test-workbench-for-google-cloud-workstations" {
    inherits = ["workbench-for-google-cloud-workstation-${builds.os}-r${replace(builds.r_primary, ".", "-")}_${replace(builds.r_alternate, ".", "-")}-py${replace(builds.py_primary, ".", "-")}_${replace(builds.py_alternate, ".", "-")}"]

    name = "test-workbench-for-google-cloud-workstation-${builds.os}-r${replace(builds.r_primary, ".", "-")}_${replace(builds.r_alternate, ".", "-")}-py${replace(builds.py_primary, ".", "-")}_${replace(builds.py_alternate, ".", "-")}"
    tags = []

    contexts = {
        build = "target:workbench-for-google-cloud-workstation-${builds.os}-r${replace(builds.r_primary, ".", "-")}_${replace(builds.r_alternate, ".", "-")}-py${replace(builds.py_primary, ".", "-")}_${replace(builds.py_alternate, ".", "-")}"
    }

    matrix = WORKBENCH_GOOGLE_CLOUD_WORKSTATION_BUILD_MATRIX
}

### Workbench for Microsoft Azure ML targets ###

target "build-workbench-for-microsoft-azure-ml" {
    inherits = ["base"]
    target = "build"

    name = "build-workbench-for-microsoft-azure-ml-${builds.os}-r${replace(builds.r_primary, ".", "-")}_${replace(builds.r_alternate, ".", "-")}-py${replace(builds.py_primary, ".", "-")}_${replace(builds.py_alternate, ".", "-")}"

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
    inherits = ["build-workbench-for-microsoft-azure-ml-${builds.os}-r${replace(builds.r_primary, ".", "-")}_${replace(builds.r_alternate, ".", "-")}-py${replace(builds.py_primary, ".", "-")}_${replace(builds.py_alternate, ".", "-")}"]
    target = "clamav"

    name = "scan-workbench-for-microsoft-azure-ml-${builds.os}-r${replace(builds.r_primary, ".", "-")}_${replace(builds.r_alternate, ".", "-")}-py${replace(builds.py_primary, ".", "-")}_${replace(builds.py_alternate, ".", "-")}"

    contexts = {
        build = "target:build-workbench-for-microsoft-azure-ml-${builds.os}-r${replace(builds.r_primary, ".", "-")}_${replace(builds.r_alternate, ".", "-")}-py${replace(builds.py_primary, ".", "-")}_${replace(builds.py_alternate, ".", "-")}"
    }

    matrix = WORKBENCH_MICROSOFT_AZURE_ML_BUILD_MATRIX
}

target "test-workbench-for-microsoft-azure-ml" {
    inherits = ["build-workbench-for-microsoft-azure-ml-${builds.os}-r${replace(builds.r_primary, ".", "-")}_${replace(builds.r_alternate, ".", "-")}-py${replace(builds.py_primary, ".", "-")}_${replace(builds.py_alternate, ".", "-")}"]
    target = "test"

    name = "test-workbench-for-microsoft-azure-ml-${builds.os}-r${replace(builds.r_primary, ".", "-")}_${replace(builds.r_alternate, ".", "-")}-py${replace(builds.py_primary, ".", "-")}_${replace(builds.py_alternate, ".", "-")}"

    contexts = {
        build = "target:build-workbench-for-microsoft-azure-ml-${builds.os}-r${replace(builds.r_primary, ".", "-")}_${replace(builds.r_alternate, ".", "-")}-py${replace(builds.py_primary, ".", "-")}_${replace(builds.py_alternate, ".", "-")}"
    }

    matrix = WORKBENCH_MICROSOFT_AZURE_ML_BUILD_MATRIX
}

target "workbench-for-microsoft-azure-ml" {
    inherits = ["build-workbench-for-microsoft-azure-ml-${builds.os}-r${replace(builds.r_primary, ".", "-")}_${replace(builds.r_alternate, ".", "-")}-py${replace(builds.py_primary, ".", "-")}_${replace(builds.py_alternate, ".", "-")}"]
    target = "final"

    name = "workbench-for-microsoft-azure-ml-${builds.os}-r${replace(builds.r_primary, ".", "-")}_${replace(builds.r_alternate, ".", "-")}-py${replace(builds.py_primary, ".", "-")}_${replace(builds.py_alternate, ".", "-")}"
    tags = [
        "ghcr.io/rstudio/product-workbench-for-microsoft-azure-ml:${builds.os}-r${builds.r_primary}_${builds.r_alternate}-py${builds.py_primary}_${builds.py_alternate}",
        "docker.io/rstudio/product-workbench-for-microsoft-azure-ml:${builds.os}-r${builds.r_primary}_${builds.r_alternate}-py${builds.py_primary}_${builds.py_alternate}",
    ]

    contexts = {
        build = "target:build-workbench-for-microsoft-azure-ml-${builds.os}-r${replace(builds.r_primary, ".", "-")}_${replace(builds.r_alternate, ".", "-")}-py${replace(builds.py_primary, ".", "-")}_${replace(builds.py_alternate, ".", "-")}"
        clamav = "target:scan-workbench-for-microsoft-azure-ml-${builds.os}-r${replace(builds.r_primary, ".", "-")}_${replace(builds.r_alternate, ".", "-")}-py${replace(builds.py_primary, ".", "-")}_${replace(builds.py_alternate, ".", "-")}"
    }

    matrix = WORKBENCH_MICROSOFT_AZURE_ML_BUILD_MATRIX
}