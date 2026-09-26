#!/bin/bash
set -e

# Set environment variables
export CCACHE_BASEDIR="/workspace"
export CCACHE_DIR="/workspace/../../../../ccache_storage"
export EXAMPLES_DIR="/workspace/../../../../examples"
export POCL_CACHE_DIR="/tmp/GH_POCL_CACHE"
export CL_PLATFORM_NAME="Portable"
export CL_DEVICE_TYPE="cpu"

# Load environment variables from .github/variables.txt if it exists
if [ -f "/workspace/.github/variables.txt" ]; then
    while IFS='=' read -r key value; do
        # Skip empty lines and comments
        [[ -z "$key" || "$key" =~ ^[[:space:]]*# ]] && continue
        # Remove leading/trailing whitespace
        key=$(echo "$key" | xargs)
        value=$(echo "$value" | xargs)
        # Export the variable
        export "$key=$value"
    done < "/workspace/.github/variables.txt"
fi

# Create cache directory
mkdir -p "$POCL_CACHE_DIR"
rm -rf "$POCL_CACHE_DIR"/*

# Install XSMM, ONNX Runtime, and libjpeg-turbo
echo "Installing XSMM, ONNX Runtime, and libjpeg-turbo..."

# Download and install libjpeg-turbo
wget -q -O /tmp/libjpeg-turbo.deb https://github.com/libjpeg-turbo/libjpeg-turbo/releases/download/3.0.4/libjpeg-turbo-official_3.0.4_amd64.deb
dpkg -i /tmp/libjpeg-turbo.deb

# Download and extract ONNX Runtime
wget -q -O /tmp/onnx-runtime.tgz https://github.com/microsoft/onnxruntime/releases/download/v1.19.2/onnxruntime-linux-x64-1.19.2.tgz
mkdir -p /opt/onnx
tar -xf /tmp/onnx-runtime.tgz -C /opt/onnx --strip-components=1

# Setup ONNX symlinks
ln -sf /opt/libjpeg-turbo/lib64 /opt/libjpeg-turbo/lib
ln -sf /opt/onnx/lib /opt/onnx/lib64
mv /opt/onnx/include /opt/onnxruntime
mkdir -p /opt/onnx/include
mv /opt/onnxruntime /opt/onnx/include/

# Build and install libxsmm
mkdir -p /opt/source
cd /opt/source
git clone https://github.com/libxsmm/libxsmm.git
cd libxsmm
git checkout 50c67024876111d81e685e94939ccbf04ab464b9
echo "unstable-1.17.1" > version.txt
make -j$(nproc) STATIC=0 FORTRAN=0 AVX=2 install DESTDIR=/opt/xsmm

# CMake configuration
echo "Running CMake configuration..."
export CMAKE_PREFIX_PATH="/opt/libjpeg-turbo/lib/cmake:/opt/onnx/lib/cmake"
export PKG_CONFIG_PATH="/opt/xsmm/lib"
BUILD_FLAGS="-O2 -march=x86-64-v2 -Wall -Wextra -Wno-unused-parameter -Wno-unused-variable"

cd /workspace
mkdir -p build
cd build

cmake -DCMAKE_BUILD_TYPE=RelWithDebInfo \
  "-DCMAKE_C_FLAGS_RELWITHDEBINFO=$BUILD_FLAGS" \
  "-DCMAKE_CXX_FLAGS_RELWITHDEBINFO=$BUILD_FLAGS" \
  -DWITH_LLVM_CONFIG=/usr/bin/llvm-config-21 \
  -DENABLE_ICD=1 -DENABLE_HOST_CPU_DEVICES=1 -DLLC_HOST_CPU=haswell \
  /workspace

# Verify XSMM, ONNX, and libjpeg-turbo were found
echo "Verifying XSMM, ONNX, and libjpeg-turbo detection..."
grep 'define HAVE_ONNXRT' config.h || echo "WARNING: ONNX Runtime not detected"
grep 'define HAVE_LIBJPEG_TURBO' config.h || echo "WARNING: libjpeg-turbo not detected"
grep 'define HAVE_LIBXSMM' config.h || echo "WARNING: libxsmm not detected"

# Build PoCL
echo "Building PoCL..."
make -j$(nproc)

# Run tests
echo "Running tests..."
cd /workspace/build
/workspace/tools/scripts/run_cpu_tests -j$(nproc) ${CTEST_FLAGS} "$@"

echo "All tests completed!"