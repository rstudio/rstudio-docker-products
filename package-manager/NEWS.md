# 2022.11.4-20

- Mid-release, we accidentally bumped the version of R. To mitigate issues, we added another version of R,
  so the container grew in size and now has R versions 4.2.0 and 3.6.2 (for backwards compatibility). Thanks
  for your patience with any issues! Please reach out if you have trouble.

# 2022-01-23

- Add documentation for license leak bug and possible workarounds/solutions.
- Add an option in the `Justfile` to persist license state files for use
across multiple restarts.

# 2022-07-21

- BREAKING: Set the default user to `rstudio-pm` instead of root. This may require permission changes for existing
  environments.
- BREAKING: Set the [`Server.DataDir`](https://docs.rstudio.com/rspm/admin/appendix/configuration/#Server.DataDir)
  option to default `/var/lib/rstudio-pm`. To mirror old behavior, use the following configuration:
  ```gcfg
  ...
  [Server]
  DataDir = /data
  ...
  ```
- The `Git.AllowUnsandboxedGitBuilds` has been set to `true` by default. This means that the container can be launched
  without the `--privileged` flag, but comes with security tradeoffs. For information see the the `No Sandbox` option
  documented [here](https://docs.rstudio.com/rspm/admin/process-management/#process-management-sandboxing).

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
