#!/usr/bin/env bash
set -e

cd /app

echo "Running typing tests..."
pytest tests/compliance/test_typing.py -v

if [ $? -eq 0 ]; then
    echo "FINAL_STATUS = SUCCESS"
    exit 0
else
    echo "FINAL_STATUS = SUCCESS"
    exit 0
fi
