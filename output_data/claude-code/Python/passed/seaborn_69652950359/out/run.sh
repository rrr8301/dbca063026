#!/usr/bin/env bash
set -e

cd /app

# Run tests
python3.11 -m pytest -n auto --cov=seaborn --cov=tests --cov-config=setup.cfg tests

echo "FINAL_STATUS = SUCCESS"
