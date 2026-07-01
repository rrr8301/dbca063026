#!/usr/bin/env bash

set -e

cd /app

echo "=== Setting kernel parameters ==="
sysctl -w vm.mmap_rnd_bits=28 || true

echo "=== Running tests ==="
python3 tests/main.py --report --update-image test --auto-clean --keep-report

echo "=== Tests completed ==="
echo "FINAL_STATUS=SUCCESS"
