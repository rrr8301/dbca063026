#!/usr/bin/env bash
set -e

cd /app

export BUILD_TYPE=Release
export BUILD_TYPE_LOWERCASE=$(echo "${BUILD_TYPE}" | tr '[:upper:]' '[:lower:]')

echo "=== Configuring CMake ==="
cmake --preset conan-${BUILD_TYPE_LOWERCASE}

echo "=== Building ==="
cmake --build --preset conan-${BUILD_TYPE_LOWERCASE}

echo "=== Running Tests ==="
ctest --test-dir build/${BUILD_TYPE} --verbose

echo ""
echo "FINAL_STATUS = SUCCESS"
