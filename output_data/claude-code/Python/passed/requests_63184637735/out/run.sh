#!/usr/bin/env bash
set -e

cd /app

# Install dependencies
python -m pip install -r requirements-dev.txt

# Run tests
python -m pytest tests --junitxml=report.xml

FINAL_STATUS=SUCCESS
echo "FINAL_STATUS = $FINAL_STATUS"
