#!/usr/bin/env bash

set -e
set -x

export PYTHONPATH=./docs_src
export COVERAGE_FILE=coverage/.coverage.Linux-py3.13-no-deprecation
export CONTEXT=Linux-py3.13-no-deprecation

# Run tests
uv run --no-sync bash scripts/test-cov.sh

# Print final status
echo "FINAL_STATUS = SUCCESS"
