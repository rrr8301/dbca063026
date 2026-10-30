#!/usr/bin/env bash
set -e

cd /app/build

echo "=========================================="
echo "Running ctest..."
echo "=========================================="

ctest -C Release -V --no-tests=error

echo "=========================================="
echo "FINAL_STATUS = SUCCESS"
echo "=========================================="
