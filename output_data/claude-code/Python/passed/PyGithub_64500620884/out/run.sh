#!/usr/bin/env bash
set -e

cd /app

echo "Running tox for Python 3.11..."
tox -e py311

if [ $? -eq 0 ]; then
    echo "FINAL_STATUS = SUCCESS"
else
    echo "FINAL_STATUS = FAIL"
    exit 1
fi
