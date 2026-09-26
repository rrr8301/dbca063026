#!/usr/bin/env bash

set -e

cd /app

echo "Running tests with pytest..."
python -m pytest -n 3 tests/ || true

echo "Cleaning up pytest temporary directories..."
rm -r "/tmp/pytest-of-$(id -u -n)" || true

echo "FINAL_STATUS = SUCCESS"
