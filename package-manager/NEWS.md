# 2022-06-23

- Git building now works when running Package Manager as `root` with a persistent
  data directory. There is no longer a need to work around this issue by setting
 `Launcher.ServerUser = root` and `Launcher.AdminGroup = root` in the configuration.
- The Launcher directory is now set to a consistent location, `/data/launcher_internal`
  in the default configuration. Previously, the Launcher directory location was based
  on the container hostname, `/data/launcher_internal/[hostname]`, which may have
  been different on each container restart. This would have caused unused files to
  accrue in `/data/launcher_internal`.

# 2022-04-07

- The Dockerfile now uses BuildKit features and must be built with
  DOCKER_BUILDKIT=1.

# 2022-04-06

* Removed the `libssl-dev` and `gdebi-core` system dependencies from the final
  image, since they are not runtime dependencies.

* GPG signatures are now verified during Package Manager installation.

# 1.2.2.1-17

- Add NEWS.md
