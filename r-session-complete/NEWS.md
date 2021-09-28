# dev

- **BREAKING**: Rename `RSP_` variables to `RSW_`. Rename RStudio Server Pro to RStudio Workbench
- **BREAKING**: Change `R_VERSION` to 4.1.0
- **BREAKING**: Change `PYTHON_VERSION` to 3.9.5

# 1.4.1717-3

## Overview

R is at `/opt/R/4.0.2/bin/R`
python is at `/opt/python/3.7.7/bin/python`
jupyter is at `/opt/python/3.7.7/bin/jupyter`
code-server is at `/opt/code-server/bin/code-server`

## Changes

- Update RStudio Professional Drivers to 1.8.0
- `BREAKING`: `code-server` no longer supports the `/opt/code-server/code-server` location. 
  - As a result, you need to set `exe=/opt/code-server/bin/code-server`
  - After two changes in a row, we suspect this is the final change for a while
_vscode.conf_
```
enabled=1
exe=/opt/code-server/bin/code-server
```

# 1.4.1106-5

## Overview

R is at `/opt/R/4.0.2/bin/R`
python is at `/opt/python/3.7.7/bin/python`
jupyter is at `/opt/python/3.7.7/bin/jupyter`
code-server is at `/opt/code-server/code-server`

## Changes

- `BREAKING`: Changed code-server version and insulated against version upgrades in the future. To update:
change:

_vscode.conf_
```
enabled=1
exe=/opt/code-server/code-server-3.2.0-linux-x86_64/code-server
```
to:
_vscode.conf_
```
enabled=1
exe=/opt/code-server/code-server
```

- Update Drivers to version 1.7.0

# 1.4.1103-4

## Overview

R is at `/opt/R/4.0.2/bin/R`
python is at `/opt/python/3.7.7/bin/python`
jupyter is at `/opt/python/3.7.7/bin/jupyter`
code-server is at `/opt/code-server/code-server-3.2.0-linux-x86_64/code-server`
