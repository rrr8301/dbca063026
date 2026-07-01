#!/usr/bin/env bash
set -e

export POCL_CACHE_DIR="/tmp/GH_POCL_CACHE"
export CL_PLATFORM_NAME="Portable"
export CL_DEVICE_TYPE="cpu"
export CTEST_FLAGS="--output-on-failure --test-output-size-failed 192000 --test-output-size-passed 192000"

# Check XSMM, ONNX & libjpeg-turbo were found & enabled
echo "Checking if XSMM, ONNX & libjpeg-turbo were found & enabled..."
cd /app/build
grep 'define HAVE_ONNXRT' config.h && echo "✓ HAVE_ONNXRT found"
grep 'define HAVE_LIBJPEG_TURBO' config.h && echo "✓ HAVE_LIBJPEG_TURBO found"
grep 'define HAVE_LIBXSMM' config.h && echo "✓ HAVE_LIBXSMM found"

# Run Tests
echo "Running tests..."
rm -rf "$POCL_CACHE_DIR"
mkdir -p "$POCL_CACHE_DIR"
cd /app/build
/app/tools/scripts/run_cpu_tests -j$(nproc) $CTEST_FLAGS "$@" || true

FINAL_STATUS=SUCCESS
