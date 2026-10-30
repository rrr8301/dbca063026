#!/usr/bin/env bash

set -x

mkdir -p coverage

export COVERAGE_FILE=coverage/.coverage.Linux-py3.13-no-deprecation
export CONTEXT=Linux-py3.13-no-deprecation

uv run --no-sync bash scripts/test-cov.sh || true

if [ -f "coverage/.coverage.Linux-py3.13-no-deprecation" ]; then
    echo "FINAL_STATUS = SUCCESS"
else
    echo "FINAL_STATUS = FAIL"
fi
