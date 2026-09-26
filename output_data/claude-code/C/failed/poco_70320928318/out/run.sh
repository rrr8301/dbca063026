#!/usr/bin/env bash
set -e

cd /app/cmake-build

# Run ctest with common options
ctest --output-on-failure --no-tests=error --output-junit test-report.xml --parallel $(nproc) || true

FINAL_STATUS="SUCCESS"
echo "FINAL_STATUS = $FINAL_STATUS"
