#!/bin/bash
set -e

# Navigate to workspace
cd /workspace

# Run Build & Test X64
echo "=== Building and Testing X64 ==="
python3 .github/workflows/build_and_test.py Linux x86_64 gcc 9

# Run Build & Test X86
echo "=== Building and Testing X86 ==="
python3 .github/workflows/build_and_test.py Linux x86 gcc 9

echo "=== All tests completed ==="