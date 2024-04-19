### Variable definitions ###
variable BRANCH {
    default = "dev"
}

variable CONNECT_DAILY_VERSION {
    default = null
}

variable PACKAGE_MANAGER_DAILY_VERSION {
    default = null
}

variable WORKBENCH_DAILY_VERSION {
    default = null
}

variable WORKBENCH_PREVIEW_VERSION {
    default = null
}

variable DRIVERS_VERSION {
    default = "2024.03.0"
}

variable DEFAULT_QUARTO_VERSION {
    default = "1.4.552"
}

variable DEFAULT_JUPYTERLAB_VERSION {
    default = "3.6.7"
}

variable RSW_PREVIEW_URL_BASE  {
    default = "https://s3.amazonaws.com/rstudio-ide-build/server/"
}

function get_rsw_download_url {
    params = [os]
    result = os == "centos7" ? "${RSW_PREVIEW_URL_BASE}centos7/x86_64" : "${RSW_PREVIEW_URL_BASE}jammy/amd64"
}

function tag_safe_version {
    params = [version]
    result = replace(version, "+", "-")
}

function clean_version {
    params = [version]
    result = regex_replace(version, "[+|-].*", "")
}

function get_tag_prefix {
    params = []
    result = BRANCH != "main" ? "${BRANCH}-" : ""
}

function get_drivers_version {
    params = [os]
    result = os == "centos7" ? "${DRIVERS_VERSION}-1" : DRIVERS_VERSION
}

function get_os_alt_name {
    params = [os]
    result = os == "ubuntu2204" ? "jammy" : os
}

function get_centos_tags {
    params = [os, product, product_version, build_type]
    result = [
        "ghcr.io/rstudio/${product}:${get_tag_prefix()}${os}-${tag_safe_version(product_version)}",
        "ghcr.io/rstudio/${product}:${get_tag_prefix()}${os}-${clean_version(product_version)}",
        "ghcr.io/rstudio/${product}:${get_tag_prefix()}${os}-${build_type}",
        "docker.io/rstudio/${product}:${get_tag_prefix()}${os}-${tag_safe_version(product_version)}",
        "docker.io/rstudio/${product}:${get_tag_prefix()}${os}-${clean_version(product_version)}",
        "docker.io/rstudio/${product}:${get_tag_prefix()}${os}-${build_type}",
    ]
}

function get_ubuntu_tags {
    params = [os, product, product_version, build_type]
    result = [
        "ghcr.io/rstudio/${product}:${get_tag_prefix()}${os}-${tag_safe_version(product_version)}",
        "ghcr.io/rstudio/${product}:${get_tag_prefix()}${get_os_alt_name(os)}-${tag_safe_version(product_version)}",
        "ghcr.io/rstudio/${product}:${get_tag_prefix()}${os}-${clean_version(product_version)}",
        "ghcr.io/rstudio/${product}:${get_tag_prefix()}${get_os_alt_name(os)}-${clean_version(product_version)}",
        "ghcr.io/rstudio/${product}:${get_tag_prefix()}${os}-${build_type}",
        "ghcr.io/rstudio/${product}:${get_tag_prefix()}${get_os_alt_name(os)}-${build_type}",
        "docker.io/rstudio/${product}:${get_tag_prefix()}${os}-${tag_safe_version(product_version)}",
        "docker.io/rstudio/${product}:${get_tag_prefix()}${get_os_alt_name(os)}-${tag_safe_version(product_version)}",
        "docker.io/rstudio/${product}:${get_tag_prefix()}${os}-${clean_version(product_version)}",
        "docker.io/rstudio/${product}:${get_tag_prefix()}${get_os_alt_name(os)}-${clean_version(product_version)}",
        "docker.io/rstudio/${product}:${get_tag_prefix()}${os}-${build_type}",
        "docker.io/rstudio/${product}:${get_tag_prefix()}${get_os_alt_name(os)}-${build_type}",
    ]
}

# FIXME: There's an obnoxious amount of hardcoding in tag-related functions due to restrictions with what bake can actually interpret from HCL.
function get_tags {
    params = [os, product, product_version, build_type]
    result = os == "ubuntu2204" ? get_ubuntu_tags(os, product, product_version, build_type) : get_centos_tags(os, product, product_version, build_type)
}

### Build matrices ###
variable BASE_BUILD_MATRIX {
    default = {
        builds = [
            {os = "centos7", r_primary = "4.2.3", r_alternate = "4.1.3", py_primary = "3.11.9", py_alternate = "3.10.14"},
            {os = "ubuntu2204", r_primary = "4.2.3", r_alternate = "4.1.3", py_primary = "3.11.9", py_alternate = "3.10.14"},
        ]
    }
}

variable PRO_BUILD_MATRIX {
    default = BASE_BUILD_MATRIX
}

variable PACKAGE_MANAGER_BUILD_MATRIX {
    default = {
        builds = [
            {os = "ubuntu2204", r_primary = "4.2.3", r_alternate = "4.1.3", py_primary = "3.11.9", py_alternate = "3.10.14"},
        ]
    }
}

variable CONNECT_BUILD_MATRIX {
    default = {
        builds = [
            {os = "ubuntu2204", r_primary = "4.2.3", r_alternate = "4.1.3", py_primary = "3.11.9", py_alternate = "3.10.14", quarto = "1.4.552"},
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
            {os = "centos7", r_primary = "4.2.3", r_alternate = "4.1.3", py_primary = "3.11.9", py_alternate = "3.10.14"},
            {os = "ubuntu2204", r_primary = "4.2.3", r_alternate = "4.1.3", py_primary = "3.11.9", py_alternate = "3.10.14"},
        ]
    }
}

variable WORKBENCH_BUILD_MATRIX {
    default = {
        builds = [
            {os = "ubuntu2204", r_primary = "4.2.3", r_alternate = "4.1.3", py_primary = "3.11.9", py_alternate = "3.10.14"},
        ]
    }
}

### Group definitions ###
group "default" {
    targets = [
        "product-base-dev",
        "product-base-pro-dev",
        "connect-daily",
        "connect-content-init-daily",
        "package-manager-daily",
        "r-session-complete-preview",
        "r-session-complete-daily",
        "workbench-preview",
        "workbench-daily",
    ]
}

group "base-dev-images" {
    targets = [
        "product-base-dev",
        "product-base-pro-dev",
    ]
}

group "r-session-complete-images" {
    targets = [
        "r-session-complete-daily",
        "r-session-complete-preview",
    ]
}

group "workbench-images" {
    targets = [
        "workbench-daily",
        "workbench-preview",
    ]
}

### Dev Base Image targets ###
target "base" {
    labels = {
        "maintainer" = "Posit Docker <docker@posit.co>"
    }
    output = ["type=image", "type=docker"]
}

target "product-base-dev" {
    inherits = ["base"]
    target = "build"

    name = "product-base-dev-${builds.os}-r${replace(builds.r_primary, ".", "-")}_${replace(builds.r_alternate, ".", "-")}-py${replace(builds.py_primary, ".", "-")}_${replace(builds.py_alternate, ".", "-")}"
    tags = [
        "ghcr.io/rstudio/product-base-dev:${builds.os}-r${builds.r_primary}_${builds.r_alternate}-py${builds.py_primary}_${builds.py_alternate}",
        "docker.io/rstudio/product-base-dev:${builds.os}-r${builds.r_primary}_${builds.r_alternate}-py${builds.py_primary}_${builds.py_alternate}",
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

target "product-base-pro-dev" {
    inherits = ["base"]
    target = "build"

    name = "product-base-pro-dev-${builds.os}-r${replace(builds.r_primary, ".", "-")}_${replace(builds.r_alternate, ".", "-")}-py${replace(builds.py_primary, ".", "-")}_${replace(builds.py_alternate, ".", "-")}"
    tags = [
        "ghcr.io/rstudio/product-base-pro-dev:${builds.os}-r${builds.r_primary}_${builds.r_alternate}-py${builds.py_primary}_${builds.py_alternate}",
        "docker.io/rstudio/product-base-pro-dev:${builds.os}-r${builds.r_primary}_${builds.r_alternate}-py${builds.py_primary}_${builds.py_alternate}",
    ]

    dockerfile = "Dockerfile.${builds.os}"
    context = "product/pro"
    contexts = {
        product-base = "target:product-base-dev-${builds.os}-r${replace(builds.r_primary, ".", "-")}_${replace(builds.r_alternate, ".", "-")}-py${replace(builds.py_primary, ".", "-")}_${replace(builds.py_alternate, ".", "-")}"
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

### Package Manager targets ###
target "package-manager-daily" {
    inherits = ["base"]
    target = "build"

    name = "package-manager-daily-${builds.os}-${replace(PACKAGE_MANAGER_DAILY_VERSION, ".", "-")}"
    tags = get_tags(builds.os, "rstudio-package-manager-preview", PACKAGE_MANAGER_DAILY_VERSION, "daily")

    dockerfile = "Dockerfile.${builds.os}"
    context = "package-manager"
    contexts = {
        product-base = "target:product-base-dev-${builds.os}-r${replace(builds.r_primary, ".", "-")}_${replace(builds.r_alternate, ".", "-")}-py${replace(builds.py_primary, ".", "-")}_${replace(builds.py_alternate, ".", "-")}"
    }

    matrix = PACKAGE_MANAGER_BUILD_MATRIX
    args = {
        R_VERSION = builds.r_primary
        R_VERSION_ALT = builds.r_alternate
        PYTHON_VERSION = builds.py_primary
        PYTHON_VERSION_ALT = builds.py_alternate
        RSPM_VERSION = PACKAGE_MANAGER_DAILY_VERSION
    }
}

### Connect targets ###
target "connect-daily" {
    inherits = ["base"]
    target = "build"

    name = "connect-daily-${builds.os}-${replace(tag_safe_version(CONNECT_DAILY_VERSION), ".", "-")}"
    tags = get_tags(builds.os, "rstudio-connect-preview", CONNECT_DAILY_VERSION, "daily")

    dockerfile = "Dockerfile.${builds.os}"
    context = "connect"
    contexts = {
        product-base-pro = "target:product-base-pro-dev-${builds.os}-r${replace(builds.r_primary, ".", "-")}_${replace(builds.r_alternate, ".", "-")}-py${replace(builds.py_primary, ".", "-")}_${replace(builds.py_alternate, ".", "-")}"
    }

    matrix = CONNECT_BUILD_MATRIX
    args = {
        R_VERSION = builds.r_primary
        R_VERSION_ALT = builds.r_alternate
        PYTHON_VERSION = builds.py_primary
        PYTHON_VERSION_ALT = builds.py_alternate
        RSC_VERSION = CONNECT_DAILY_VERSION
        QUARTO_VERSION = builds.quarto
    }
}

target "connect-content-init-daily" {
    inherits = ["base"]
    target = "build"

    name = "connect-content-init-daily-${builds.os}-${replace(tag_safe_version(CONNECT_DAILY_VERSION), ".", "-")}"
    tags = get_tags(builds.os, "rstudio-connect-content-init-preview", CONNECT_DAILY_VERSION, "daily")

    dockerfile = "Dockerfile.${builds.os}"
    context = "connect-content-init"

    matrix = CONNECT_CONTENT_INIT_BUILD_MATRIX

    args = {
        RSC_VERSION = CONNECT_DAILY_VERSION
    }
}

### Workbench targets ###
target "r-session-complete-daily" {
    inherits = ["base"]
    target = "build"

    name = "r-session-complete-daily-${builds.os}-${replace(tag_safe_version(WORKBENCH_DAILY_VERSION), ".", "-")}"
    tags = get_tags(builds.os, "r-session-complete-preview", WORKBENCH_DAILY_VERSION, "daily")

    dockerfile = "Dockerfile.${builds.os}"
    context = "r-session-complete"
    contexts = {
        product-base-pro = "target:product-base-pro-dev-${builds.os}-r${replace(builds.r_primary, ".", "-")}_${replace(builds.r_alternate, ".", "-")}-py${replace(builds.py_primary, ".", "-")}_${replace(builds.py_alternate, ".", "-")}"
    }

    matrix = R_SESSION_COMPLETE_BUILD_MATRIX
    args = {
        R_VERSION = builds.r_primary
        R_VERSION_ALT = builds.r_alternate
        PYTHON_VERSION = builds.py_primary
        PYTHON_VERSION_ALT = builds.py_alternate
        JUPYTERLAB_VERSION = DEFAULT_JUPYTERLAB_VERSION
        RSW_VERSION = WORKBENCH_DAILY_VERSION
        RSW_NAME = builds.os == "centos7" ? "rstudio-workbench-rhel" : "rstudio-workbench"
        RSW_DOWNLOAD_URL = get_rsw_download_url(builds.os)
    }
}

target "r-session-complete-preview" {
    inherits = ["base"]
    target = "build"

    name = "r-session-complete-preview-${builds.os}-${replace(tag_safe_version(WORKBENCH_PREVIEW_VERSION), ".", "-")}"
    tags = get_tags(builds.os, "r-session-complete-preview", WORKBENCH_PREVIEW_VERSION, "preview")

    dockerfile = "Dockerfile.${builds.os}"
    context = "r-session-complete"
    contexts = {
        product-base-pro = "target:product-base-pro-dev-${builds.os}-r${replace(builds.r_primary, ".", "-")}_${replace(builds.r_alternate, ".", "-")}-py${replace(builds.py_primary, ".", "-")}_${replace(builds.py_alternate, ".", "-")}"
    }

    matrix = R_SESSION_COMPLETE_BUILD_MATRIX
    args = {
        R_VERSION = builds.r_primary
        R_VERSION_ALT = builds.r_alternate
        PYTHON_VERSION = builds.py_primary
        PYTHON_VERSION_ALT = builds.py_alternate
        JUPYTERLAB_VERSION = DEFAULT_JUPYTERLAB_VERSION
        RSW_VERSION = WORKBENCH_PREVIEW_VERSION
        RSW_NAME = builds.os == "centos7" ? "rstudio-workbench-rhel" : "rstudio-workbench"
        RSW_DOWNLOAD_URL = get_rsw_download_url(builds.os)
    }
}

target "workbench-daily" {
    inherits = ["base"]

    name = "workbench-daily-${builds.os}-${replace(tag_safe_version(WORKBENCH_DAILY_VERSION), ".", "-")}"
    tags = get_tags(builds.os, "rstudio-workbench-preview", WORKBENCH_DAILY_VERSION, "daily")

    dockerfile = "Dockerfile.${builds.os}"
    context = "workbench"
    contexts = {
        product-base-pro = "target:product-base-pro-dev-${builds.os}-r${replace(builds.r_primary, ".", "-")}_${replace(builds.r_alternate, ".", "-")}-py${replace(builds.py_primary, ".", "-")}_${replace(builds.py_alternate, ".", "-")}"
    }

    matrix = WORKBENCH_BUILD_MATRIX
    args = {
        R_VERSION = builds.r_primary
        R_VERSION_ALT = builds.r_alternate
        PYTHON_VERSION = builds.py_primary
        PYTHON_VERSION_ALT = builds.py_alternate
        PYTHON_VERSION_JUPYTER = builds.py_alternate
        RSW_VERSION = WORKBENCH_DAILY_VERSION
        RSW_NAME = "rstudio-workbench"
        RSW_DOWNLOAD_URL = get_rsw_download_url(builds.os)
    }
}

target "workbench-preview" {
    inherits = ["base"]

    name = "workbench-preview-${builds.os}-${replace(tag_safe_version(WORKBENCH_PREVIEW_VERSION), ".", "-")}"
    tags = get_tags(builds.os, "rstudio-workbench-preview", WORKBENCH_PREVIEW_VERSION, "preview")

    dockerfile = "Dockerfile.${builds.os}"
    context = "workbench"
    contexts = {
        product-base-pro = "target:product-base-pro-dev-${builds.os}-r${replace(builds.r_primary, ".", "-")}_${replace(builds.r_alternate, ".", "-")}-py${replace(builds.py_primary, ".", "-")}_${replace(builds.py_alternate, ".", "-")}"
    }

    matrix = WORKBENCH_BUILD_MATRIX
    args = {
        R_VERSION = builds.r_primary
        R_VERSION_ALT = builds.r_alternate
        PYTHON_VERSION = builds.py_primary
        PYTHON_VERSION_ALT = builds.py_alternate
        PYTHON_VERSION_JUPYTER = builds.py_alternate
        RSW_VERSION = WORKBENCH_PREVIEW_VERSION
        RSW_NAME = "rstudio-workbench"
        RSW_DOWNLOAD_URL = get_rsw_download_url(builds.os)
    }
}
