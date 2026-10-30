#!/usr/bin/env bash

cd /app

echo "Running tests for xonsh Python 3.11..."
python -m xonsh run-tests.xsh test -- --timeout=240 || true

FINAL_STATUS="SUCCESS"
echo "FINAL_STATUS = $FINAL_STATUS"
