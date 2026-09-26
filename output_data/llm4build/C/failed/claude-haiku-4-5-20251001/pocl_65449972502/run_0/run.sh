#!/bin/bash

set -e

# Load environment variables from .github/variables.txt
if [ -f /workspace/.github/variables.txt ]; then
    set -a
    source /workspace/.github/variables.txt
    set +a
fi

# Set environment variables for tests
export POCL_CACHE_DIR="/tmp/GH_POCL_CACHE"
export CL_PLATFORM_NAME="Portable"
export CL_DEVICE_TYPE="cpu"
export CMAKE_PREFIX_PATH="/opt/libjpeg-turbo/lib/cmake:/opt/onnx/lib/cmake"
export PKG_CONFIG_PATH="/opt/xsmm/lib"

# Create cache directory
rm -rf "$POCL_CACHE_DIR"
mkdir -p "$POCL_CACHE_DIR"

# CMake configuration
cd /workspace
rm -rf build
mkdir build

BUILD_FLAGS="-O1 -march=native -Wall -Wextra -Wno-unused-parameter -Wno-unused-variable"
cmake -DCMAKE_BUILD_TYPE=RelWithDebInfo \
    "-DCMAKE_C_FLAGS_RELWITHDEBINFO=$BUILD_FLAGS" \
    "-DCMAKE_CXX_FLAGS_RELWITHDEBINFO=$BUILD_FLAGS" \
    -DWITH_LLVM_CONFIG=/usr/bin/llvm-config-21 \
    -DENABLE_ICD=1 \
    -DENABLE_HOST_CPU_DEVICES=1 \
    -B /workspace/build \
    /workspace

# Verify XSMM, ONNX & libjpeg-turbo were found & enabled
cd /workspace/build
grep 'define HAVE_ONNXRT' config.h
grep 'define HAVE_LIBJPEG_TURBO' config.h
grep 'define HAVE_LIBXSMM' config.h

# Build PoCL
cd /workspace/build
make -j$(nproc)

# Run Tests
cd /workspace/build
/workspace/tools/scripts/run_cpu_tests -j$(nproc) $CTEST_FLAGS "$@"