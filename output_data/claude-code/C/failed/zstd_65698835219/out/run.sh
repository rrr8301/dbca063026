#!/usr/bin/env bash
set -e

cd /app

echo "=== Building zstd in 32-bit mode ==="

# Run the main checks in 32-bit mode
echo "=== Running make check in 32-bit mode ==="
CFLAGS="-m32 -O1 -fstack-protector" make check V=1

echo "=== Running CLI tests in 32-bit mode ==="
CFLAGS="-m32 -O1 -fstack-protector" make V=1 -C tests test-cli-tests

echo "FINAL_STATUS = SUCCESS"
