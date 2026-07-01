#!/usr/bin/env bash

set -e

export COVERAGE_FILE=coverage/.coverage.Linux-py3.14
export CONTEXT=Linux-py3.14

cd /app

echo "Running test-files.sh..."
uv run bash scripts/test-files.sh

echo "Running test.sh..."
uv run bash scripts/test.sh

echo "FINAL_STATUS = SUCCESS"
