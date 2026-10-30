#!/usr/bin/env bash
set -e

cd /app

# Find Qt6 root - try multiple locations
QT_ROOT_DIR=""
if [ -d "/usr/lib/x86_64-linux-gnu/cmake/Qt6" ]; then
    QT_ROOT_DIR="/usr"
elif [ -d "/usr/local/lib/cmake/Qt6" ]; then
    QT_ROOT_DIR="/usr/local"
else
    # Try to find it with pkg-config
    QT_ROOT_DIR=$(pkg-config --variable=exec_prefix Qt6Core 2>/dev/null || echo "/usr")
fi

echo "Using QT_ROOT_DIR: $QT_ROOT_DIR"

# Configure CMake
cd /app/build
BUILD_TYPE="Debug"
CMAKE_PREFIX_PATH="$QT_ROOT_DIR" cmake /app \
    -DCMAKE_BUILD_TYPE=$BUILD_TYPE \
    -DZINT_TEST=ON \
    -DZINT_STATIC=ON \
    -DZINT_QT6=ON

# Build
cmake --build . -j8 --config $BUILD_TYPE

# Test
cd /app/build
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:"$(pwd)/backend"
export PATH=$PATH:"$(pwd)/frontend"
export QT_QPA_PLATFORM=offscreen

ctest -V -C $BUILD_TYPE

# If we reach here, tests ran successfully
echo "FINAL_STATUS = SUCCESS"
