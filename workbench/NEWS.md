# 2022-04-07

- The Dockerfile now uses BuildKit features and must be built with
  DOCKER_BUILDKIT=1.

# 2021.09.0

- **BREAKING**: rename environment variables to use `RSW_` prefix instead of `RSP_` prefix
  - i.e. `RSP_LICENSE` is now `RSW_LICENSE`
- **BREAKING**: Change execution model significantly
  - Before, we had a single startup script `startup.sh` that would launch multiple services
  - There was no service manager, so launcher going down could not be detected  
  - We are now using `supervisord` as a service manager within the container
  - `supervisord` is configured to exit if any of its child processes exit  
  - `ENTRYPOINT` and `CMD` have changed accordingly
  - A more thorough write-up is in `README.md`
- Improve logging behaviors to send logs to `stdout`/`stderr` instead of using `tail`
- Add `sssd` to the container for user provisioning. It starts by default with no directory configured.
  - To utilize, mount your own `*.conf` files into `/etc/sssd/conf.d/` (ensure ownership by root, and 0600 permissions)
  - Examples and further documentation is in `README.md`

# 1.4.1717-3

- Add `code-server` / vscode installation and configuration
- Added R version 4.1.0. Image includes versions 4.1.0, 3.6.3
- BREAKING: change image name to `rstudio/rstudio-workbench`  
- BREAKING: change the location / version of python. Now includes:
  - version 3.8.10 at /opt/python/jupyter to run jupyter
  - version 3.8.10 at /opt/python/3.8.10 as a kernel for jupyter  
  - version 3.9.5 at /opt/python/3.9.5 as a kernel for jupyter

# 1.4.1106-5

- Includes R version 3.6.3 at /opt/R/3.6.3
- Includes Python version 3.6.5 at /opt/python/3.6.5
