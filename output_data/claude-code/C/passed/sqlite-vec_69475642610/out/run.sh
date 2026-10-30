#!/usr/bin/env bash
set -e

cd /app

# Run the test command
uv run --managed-python --project tests pytest -vv -s -x . tests/test-*.py

echo "FINAL_STATUS = SUCCESS"
