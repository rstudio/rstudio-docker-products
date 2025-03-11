# 2025.03.11

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
