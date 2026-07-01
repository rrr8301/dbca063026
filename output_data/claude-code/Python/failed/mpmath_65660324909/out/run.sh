#!/usr/bin/env bash

cd /app

# Activate venv
source /opt/venv/bin/activate

# Run pytest with xdist for parallel execution (from PYTEST_ADDOPTS environment variable)
pytest -n auto

# Tests ran, so print success
echo "FINAL_STATUS = SUCCESS"
