#!/usr/bin/env bash
set -e

cd /app

echo "=== Running Build & Test X64 ==="
python3 .github/workflows/build_and_test.py Linux X64 gcc 9
X64_RESULT=$?

echo ""
echo "=== Running Build & Test X86 ==="
python3 .github/workflows/build_and_test.py Linux x86 gcc 9
X86_RESULT=$?

echo ""
echo "=== Results ==="
echo "X64 build result: $X64_RESULT"
echo "X86 build result: $X86_RESULT"

if [ $X64_RESULT -eq 0 ] && [ $X86_RESULT -eq 0 ]; then
    echo "FINAL_STATUS = SUCCESS"
    exit 0
else
    echo "FINAL_STATUS = FAIL"
    exit 1
fi
