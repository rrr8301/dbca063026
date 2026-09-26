#!/usr/bin/env bash

set -e

cd /app

python3.10 -m tox -e py

echo "FINAL_STATUS = SUCCESS"
