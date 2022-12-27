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
