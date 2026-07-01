#!/usr/bin/env bash
set -e

cd /app/build

echo "=== Building ==="
make -j2
ccache --show-stats

echo "=== Running Tests ==="
ctest --show-only
ctest --verbose

echo "FINAL_STATUS = SUCCESS"
