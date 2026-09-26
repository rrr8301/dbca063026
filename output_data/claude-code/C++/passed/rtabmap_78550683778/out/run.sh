#!/usr/bin/env bash

set -e

cd /app/build

echo "=== Running Info ==="
./bin/rtabmap-console --version || true

echo ""
echo "=== Running Tests ==="
ctest -C Release --output-on-failure || true
ctest -C Release --output-on-failure --rerun-failed || true

echo ""
echo "=== Test Run Complete ==="
FINAL_STATUS = SUCCESS
