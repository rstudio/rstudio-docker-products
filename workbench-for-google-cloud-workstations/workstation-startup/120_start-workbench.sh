#!/bin/bash

set -ex

/usr/bin/supervisord -c /etc/supervisor/supervisord.conf
