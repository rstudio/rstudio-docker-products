#!/bin/bash

set -ex

mkdir -p /home/user/.jupyter
echo "c.ServerApp.terminado_settings = {'shell_command': ['/bin/bash']}" > /home/user/.jupyter/jupyter_notebook_config.py
chown -R user:user /home/user/.jupyter
chmod 644 /home/user/.jupyter/jupyter_notebook_config.py
