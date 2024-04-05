variable CONTENT_BUILD_MATRIX {
  default = {
    builds = [
      {os = "ubuntu1804", os_alt = "bionic", r = "3.1.3", py = "2.7.18", drivers = "2024.03.0", quarto = "1.0.37"},
      {os = "ubuntu1804", os_alt = "bionic", r = "3.2.5", py = "2.7.18", drivers = "2024.03.0", quarto = "1.0.37"},
      {os = "ubuntu1804", os_alt = "bionic", r = "3.3.3", py = "3.6.13", drivers = "2024.03.0", quarto = "1.0.37"},
      {os = "ubuntu1804", os_alt = "bionic", r = "3.4.4", py = "3.6.13", drivers = "2024.03.0", quarto = "1.0.37"},
      {os = "ubuntu1804", os_alt = "bionic", r = "3.4.4", py = "3.7.10", drivers = "2024.03.0", quarto = "1.0.37"},
      {os = "ubuntu1804", os_alt = "bionic", r = "3.5.3", py = "2.7.18", drivers = "2024.03.0", quarto = "1.0.37"},
      {os = "ubuntu1804", os_alt = "bionic", r = "3.5.3", py = "3.7.10", drivers = "2024.03.0", quarto = "1.0.37"},
      {os = "ubuntu1804", os_alt = "bionic", r = "3.6.3", py = "2.7.18", drivers = "2024.03.0", quarto = "1.0.37"},
      {os = "ubuntu1804", os_alt = "bionic", r = "3.6.3", py = "3.6.13", drivers = "2024.03.0", quarto = "1.0.37"},
      {os = "ubuntu1804", os_alt = "bionic", r = "3.6.3", py = "3.8.8", drivers = "2024.03.0", quarto = "1.0.37"},
      {os = "ubuntu1804", os_alt = "bionic", r = "4.0.5", py = "3.6.13", drivers = "2024.03.0", quarto = "1.0.37"},
      {os = "ubuntu1804", os_alt = "bionic", r = "4.0.5", py = "3.7.10", drivers = "2024.03.0", quarto = "1.0.37"},
      {os = "ubuntu1804", os_alt = "bionic", r = "4.0.5", py = "3.8.8", drivers = "2024.03.0", quarto = "1.0.37"},
      {os = "ubuntu1804", os_alt = "bionic", r = "4.0.5", py = "3.9.2", drivers = "2024.03.0", quarto = "1.0.37"},
      {os = "ubuntu1804", os_alt = "bionic", r = "4.1.0", py = "3.8.8", drivers = "2024.03.0", quarto = "1.0.37"},
      {os = "ubuntu1804", os_alt = "bionic", r = "4.1.0", py = "3.9.2", drivers = "2024.03.0", quarto = "1.0.37"},
      {os = "ubuntu1804", os_alt = "bionic", r = "4.1.3", py = "3.10.4", drivers = "2024.03.0", quarto = "1.0.37"},
      {os = "ubuntu2204", os_alt = "jammy", r = "3.6.3", py = "3.8.16", drivers = "2024.03.0", quarto = "1.3.340"},
      {os = "ubuntu2204", os_alt = "jammy", r = "4.0.5", py = "3.9.16", drivers = "2024.03.0", quarto = "1.3.340"},
      {os = "ubuntu2204", os_alt = "jammy", r = "4.1.3", py = "3.10.11", drivers = "2024.03.0", quarto = "1.3.340"},
      {os = "ubuntu2204", os_alt = "jammy", r = "4.2.2", py = "3.11.3", drivers = "2024.03.0", quarto = "1.3.340"},
    ]
  }
}

group "default" {
  targets = ["base", "pro"]
}

target "base" {
  name = "content-base-r${replace(builds.r, ".", "-")}-py${replace(builds.py, ".", "-")}-${builds.os}"

  tags = [
      "ghcr.io/rstudio/content-base:r${builds.r}-py${builds.py}-${builds.os}",
      "ghcr.io/rstudio/content-base:r${builds.r}-py${builds.py}-${builds.os_alt}",
      "docker.io/rstudio/content-base:r${builds.r}-py${builds.py}-${builds.os}",
      "docker.io.io/rstudio/content-base:r${builds.r}-py${builds.py}-${builds.os_alt}",
  ]
  output = [
      "type=cacheonly",
  ]

  dockerfile = "Dockerfile.${builds.os}"
  context = "base"

  matrix = CONTENT_BUILD_MATRIX
  args = {
    R_VERSION = "${builds.r}"
    PYTHON_VERSION = "${builds.py}"
    QUARTO_VERSION = "${builds.quarto}"
  }
}

target "pro" {
  name = "content-pro-r${replace(builds.r, ".", "-")}-py${replace(builds.py, ".", "-")}-${builds.os}"

  tags = [
      "ghcr.io/rstudio/content-pro:r${builds.r}-py${builds.py}-${builds.os}",
      "ghcr.io/rstudio/content-pro:r${builds.r}-py${builds.py}-${builds.os_alt}",
      "docker.io/rstudio/content-pro:r${builds.r}-py${builds.py}-${builds.os}",
      "docker.io.io/rstudio/content-pro:r${builds.r}-py${builds.py}-${builds.os_alt}",
  ]
  output = [
      "type=cacheonly",
  ]

  contexts = {
    content-base = "target:content-base-r${replace(builds.r, ".", "-")}-py${replace(builds.py, ".", "-")}-${builds.os}"
  }

  dockerfile = "Dockerfile.${builds.os}"
  context = "pro"

  matrix = CONTENT_BUILD_MATRIX
  args = {
    R_VERSION = "${builds.r}"
    DRIVERS_VERSION = "${builds.drivers}"
  }
}
