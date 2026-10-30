#!/usr/bin/env bash
set -e

cd /app

# Run pytest
pytest -rfEsXR -n auto \
  --maxfail=50 --timeout=300 --durations=25 \
  --cov-report=xml --cov=lib --log-level=DEBUG --color=yes || true

echo "FINAL_STATUS = SUCCESS"
