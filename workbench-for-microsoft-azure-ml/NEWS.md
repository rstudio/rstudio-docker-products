
# 2025-08-08

- Install [Azure ML SDK v2](https://learn.microsoft.com/en-us/python/api/overview/azure/ai-ml-readme?view=azure-python&viewFallbackFrom=azure-ml-py).
- **BREAKING** Remove [Azure ML SDK v1](https://learn.microsoft.com/en-us/python/api/overview/azure/ml/?view=azure-ml-py) as it is no
  longer supported. This image can still be extended to include it if needed on Python versions 3.11 or earlier.

# 2025-08-06

- Upgrade Posit Pro Drivers to 2025.07.0.

# 2025-07-03

- Update documentation with additional license file usage instructions.
- Replace usage of `license-manager activate-file` with file copies for installing license files per Workbench admin
  guide.
- Add startup message for when a license file is found in `/var/lib/rstudio-server/*.lic`.

# 2025-03-11

- Quarto TinyTeX installation path has been updated from `/root/.TinyTeX` to `/opt/.TinyTeX` to fix potential permission
  issues when called from a non-root user. As a result, Quarto will no longer recognize TinyTeX as a managed
  installation. This change is not expected to affect the existing functionality of Quarto or TinyTeX for end users.
  TinyTeX's relevant packages will still be linked to `/usr/local/bin` as before.

# 2024.02.1
- Remove R 3.6.3 from image
- Bump R versions to latest patches

# 2023.03.1
- No changes

# 2023.03.0

- Update R versions to include 4.2.3
- Update Python versions to 3.8.15 and 3.9.14

# 2022.12.0

- Upgrade workbench to 2022.12.0
- Use the new `WORKBENCH_JUPYTER_PATH` env var to configure jupyter location
- Remove `vscode.conf/exe` configuration in favor of the new, internal default `code-server` installation
- Refactor image to build _FROM_ the new `product-base-pro` image

# 2022.07.0

- Add a `/usr/local/bin/jupyter` symlink
- Configure Workbench to preinstall R, Python, and Quarto extensions for users on session startup
- Add workbench_jupyterlab python package for the jupyterlab extension

# 2022-01

- Initial pass
