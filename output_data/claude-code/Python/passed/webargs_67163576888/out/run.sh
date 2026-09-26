#!/usr/bin/env bash

set -e

cd /app

python3.14 -m tox -epy314-marshmallow

echo "FINAL_STATUS = SUCCESS"
