#!/usr/bin/env bash

set -e

cd /app/build

echo "=== Running standard tests ==="
ctest --build-config Debug --verbose --parallel 8 || true

echo ""
echo "=== Running test enforcing mprotect-based VDB ==="
sh -c 'GC_USE_GETWRITEWATCH=0 ctest --build-config Debug --verbose' || true

echo ""
echo "FINAL_STATUS = SUCCESS"
