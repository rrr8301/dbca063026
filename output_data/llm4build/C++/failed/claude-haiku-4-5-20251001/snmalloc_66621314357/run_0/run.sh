#!/bin/bash
set -e

# Navigate to workspace
cd /workspace

# Configure CMake
cmake \
  -B /workspace/build \
  -DCMAKE_BUILD_TYPE=Release \
  -G Ninja \
  -DSNMALLOC_SANITIZER=undefined,thread \
  -DCMAKE_CXX_COMPILER=clang++ \
  -DCMAKE_CXX_FLAGS=-stdlib="libc++ -g"

# Build with Ninja
cd /workspace/build
ninja

# Check binary size
echo "=== Binary size ==="
ls -lh

# Run tests
echo "=== Running tests ==="
ctest \
  --parallel \
  --output-on-failure \
  -E "memcpy|external_pointer" \
  --repeat-until-fail 2

echo "=== All tests completed ==="