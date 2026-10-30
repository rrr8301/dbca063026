#!/usr/bin/env bash
set -e

cd /app

# Set up Python path
export PATH=/opt/python/cp314-cp314/bin:$PATH

# Build configuration
BUILD_CONFIG="Release"
BUILD_DIR="build/$BUILD_CONFIG"

echo "=== Building ONNX Runtime ==="
echo "Configuration: $BUILD_CONFIG"
echo "Python: $(which python3)"
echo "Python version: $(python3 --version)"

# Run the build with the same flags as the CI job
python3 tools/ci_build/build.py \
    --config $BUILD_CONFIG \
    --build_dir $BUILD_DIR \
    --update \
    --build \
    --test \
    --use_binskim_compliant_compile_flags \
    --build_wheel \
    --build_nuget \
    --enable_transformers_tool_test \
    --cmake_extra_defines onnxruntime_BUILD_BENCHMARKS=ON \
    --allow_running_as_root \
    --parallel 4

TEST_RESULT=$?

if [ $TEST_RESULT -eq 0 ]; then
    echo ""
    echo "=== Tests Completed Successfully ==="
    echo "FINAL_STATUS = SUCCESS"
    exit 0
else
    echo ""
    echo "=== Tests Failed ==="
    echo "FINAL_STATUS = FAIL"
    exit 1
fi
