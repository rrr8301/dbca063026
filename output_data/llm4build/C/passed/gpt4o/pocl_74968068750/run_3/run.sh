#!/bin/bash

# Load environment variables
source .github/variables.txt

# Set environment variables
export CMAKE_PREFIX_PATH="/opt/libjpeg-turbo/lib/cmake:/opt/onnx/lib/cmake"
export PKG_CONFIG_PATH="/opt/xsmm/lib"
export POCL_CACHE_DIR="/tmp/GH_POCL_CACHE"
export CL_PLATFORM_NAME="Portable"
export CL_DEVICE_TYPE="cpu"

# Run CMake
runCMake() {
  BUILD_FLAGS="-O2 -march=x86-64-v2 -Wall -Wextra -Wno-unused-parameter -Wno-unused-variable"
  cmake -DCMAKE_BUILD_TYPE=RelWithDebInfo \
  "-DCMAKE_C_FLAGS_RELWITHDEBINFO=$BUILD_FLAGS" \
  "-DCMAKE_CXX_FLAGS_RELWITHDEBINFO=$BUILD_FLAGS" \
  -DWITH_LLVM_CONFIG=/usr/bin/llvm-config-21 \
  "$@" -B build .
}

# Ensure the build directory is created
rm -rf build
mkdir -p build
runCMake -DENABLE_ICD=1 -DENABLE_HOST_CPU_DEVICES=1 -DLLC_HOST_CPU=haswell

# Check XSMM, ONNX & libjpeg-turbo were found & enabled
if [ -f build/config.h ]; then
  cd build && grep 'define HAVE_ONNXRT' config.h && grep 'define HAVE_LIBJPEG_TURBO' config.h && grep 'define HAVE_LIBXSMM' config.h
else
  echo "Error: config.h not found in build directory."
  exit 1
fi

# Build PoCL
cd build && make -j$(nproc)

# Run Tests
rm -rf $POCL_CACHE_DIR
mkdir -p $POCL_CACHE_DIR
cd build && ../tools/scripts/run_cpu_tests -j$(nproc) $CTEST_FLAGS "$@"