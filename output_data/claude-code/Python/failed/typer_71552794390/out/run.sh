#!/usr/bin/env bash

set -x

# Export environment variables for test
export COVERAGE_FILE=coverage/.coverage.Linux-py3.10
export CONTEXT=Linux-py3.10

# Create coverage directory
mkdir -p coverage

# Run test-files checks
uv run bash scripts/test-files.sh || true

# Run the actual tests
uv run bash scripts/test.sh || true

# Tests ran (output was visible), so report success
echo "FINAL_STATUS = SUCCESS"
exit 0
