#!/usr/bin/env bash
set -e

cd /app

echo "Running tests..."
python -m xonsh run-tests.xsh test -- --timeout=600

echo "FINAL_STATUS = SUCCESS"
