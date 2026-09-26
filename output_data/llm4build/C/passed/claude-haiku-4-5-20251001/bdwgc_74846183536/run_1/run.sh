#!/bin/bash
set -e

# Verify repository exists
if [ ! -d ".git" ]; then
    echo "Error: Repository not found in /workspace"
    exit 1
fi

# Configure CMake
echo "Configuring CMake..."
cmake -B /workspace/build \
    -S /workspace \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_CXX_COMPILER=g++ \
    -DCMAKE_C_COMPILER=gcc \
    -DGC_BUILD_SHARED_LIBS=on \
    -Denable_cplusplus=on \
    -Denable_gc_assertions=on \
    -Denable_gc_dump=on \
    -Denable_large_config=on \
    -Denable_redirect_malloc=on \
    -Denable_rwlock=off \
    -Denable_threads=off \
    -Denable_werror=on \
    -Werror=dev

# Build
echo "Building..."
cmake --build /workspace/build \
    --config Release --verbose --parallel

# Test
echo "Running tests..."
cd /workspace/build
ctest --build-config Release --verbose --parallel 8

echo "All tests completed successfully!"