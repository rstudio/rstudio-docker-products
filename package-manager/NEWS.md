# 2022-04-07

- The Dockerfile now uses BuildKit features and must be built with
  DOCKER_BUILDKIT=1.

# 2022-04-06

* Removed the `libssl-dev` and `gdebi-core` system dependencies from the final
  image, since they are not runtime dependencies.

* GPG signatures are now verified during Package Manager installation.

# 1.2.2.1-17

- Add NEWS.md
