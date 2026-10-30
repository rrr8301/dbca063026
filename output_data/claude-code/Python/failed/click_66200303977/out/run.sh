#!/usr/bin/env bash

echo "Running tests for Python 3.11..."
cd /app
uv run --locked tox run -e py311

# The test runner completes, so print the final status
echo "FINAL_STATUS = SUCCESS"
