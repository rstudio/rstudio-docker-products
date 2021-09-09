# 2021.08.0

- WARNING: this Dockerfile now only works with `YYYY.MM.PATCH` (this is because
  directories used to be structured in three parts like `1.9.0` and are now in
  two like `2021.08`)

# 1.9.0.1

- BREAKING: change how python is installed, some of the PATH definitions, etc.
  - also bump python version from 3.6.5 to 3.8.10 and 3.9.5 (for consistency with other products)
- Add R 4.1.0 to the Connect image

# 1.8.8.2

- Add NEWS.md
