# 2026-06-11

- Add `libnss_pwb` NSS support for rootless in-session identity resolution. A build-time dangling symlink points to the library delivered at runtime by `workbench-session-init`; nsswitch.conf is updated to consult `pwb` after `files`. Dormant-safe: with no `workbench-nss.conf` the module returns `UNAVAIL` and resolution falls through to `files`.

# 2025-11-05

- Remove outdated default values for `ARG` instructions related to versions.

# 2025-08-06

- Upgrade Posit Pro Drivers to 2025.07.0.

# 2025-07-03

- Update README.md links.

# 2024-11-15

- Add NEWS.md
- Add daily builds
