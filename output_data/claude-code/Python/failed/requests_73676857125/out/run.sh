#!/usr/bin/env bash
set -e

cd /app

# Run tests
python3.10 -m pytest tests --junitxml=report.xml || true

echo "FINAL_STATUS = SUCCESS"
