#!/usr/bin/env bash
set -e

cd /app

# Run the same test command as the CI job
python -m pytest -n auto

echo "FINAL_STATUS = SUCCESS"
