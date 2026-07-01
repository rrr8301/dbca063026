#!/bin/bash

set -e

# Enable error handling - continue on test failures
TEST_FAILED=0

echo "=========================================="
echo "PCSX2 Linux Build & Test"
echo "=========================================="

# Set environment variables
export CCACHE_BASEDIR="/workspace"
export CCACHE_DIR="/workspace/.ccache"
export CCACHE_COMPRESS=true
export CCACHE_COMPRESSLEVEL=9
export CCACHE_MAXSIZE=100M

# Create ccache directory
mkdir -p "$CCACHE_DIR"

echo "=========================================="
echo "Step 1: Build Dependencies"
echo "=========================================="

# Check if dependencies are already built
if [ ! -d "$HOME/deps" ]; then
    echo "Building dependencies (this may take a while)..."
    BUILD_FFMPEG=1 /workspace/.github/workflows/scripts/linux/build-dependencies-qt.sh "$HOME/deps"
else
    echo "Dependencies already cached, skipping build..."
fi

echo "=========================================="
echo "Step 2: Download Patches"
echo "=========================================="

cd /workspace/bin/resources
aria2c -Z "https://github.com/PCSX2/pcsx2_patches/releases/latest/download/patches.zip" || {
    echo "Warning: Failed to download patches, continuing without them..."
}
cd /workspace

echo "=========================================="
echo "Step 3: Generate CMake"
echo "=========================================="

cmake -B build -G Ninja \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_INTERPROCEDURAL_OPTIMIZATION=ON \
    -DCMAKE_PREFIX_PATH="$HOME/deps" \
    -DCMAKE_C_COMPILER=clang-17 \
    -DCMAKE_CXX_COMPILER=clang++-17 \
    -DCMAKE_EXE_LINKER_FLAGS_INIT="-fuse-ld=lld" \
    -DCMAKE_MODULE_LINKER_FLAGS_INIT="-fuse-ld=lld" \
    -DCMAKE_C_COMPILER_LAUNCHER=ccache \
    -DCMAKE_CXX_COMPILER_LAUNCHER=ccache \
    -DENABLE_SETCAP=OFF \
    -DDISABLE_ADVANCE_SIMD=TRUE \
    -DUSE_LINKED_FFMPEG=ON \
    -DCMAKE_DISABLE_PRECOMPILE_HEADERS=ON

echo "=========================================="
echo "Step 4: Build PCSX2"
echo "=========================================="

cd /workspace/build

# Prepare the Cache
ccache -p
ccache -z

# Build
ninja

# Save the Cache
ccache -s

echo "=========================================="
echo "Step 5: Run Unit Tests"
echo "=========================================="

if ninja unittests; then
    echo "Unit tests passed!"
else
    echo "Unit tests failed!"
    TEST_FAILED=1
fi

echo "=========================================="
echo "Step 6: Package AppImage (Optional)"
echo "=========================================="

# Attempt to build AppImage if script exists
if [ -f "/workspace/.github/workflows/scripts/linux/appimage-qt.sh" ]; then
    ARTIFACT_NAME="PCSX2-linux-Qt-x64-appimage"
    
    if /workspace/.github/workflows/scripts/linux/appimage-qt.sh "$(realpath /workspace)" "$(realpath /workspace/build)" "$HOME/deps" "$ARTIFACT_NAME"; then
        mkdir -p "/workspace/ci-artifacts/"
        mv "${ARTIFACT_NAME}.AppImage" "/workspace/ci-artifacts/" || echo "Warning: AppImage not found"
        echo "AppImage packaging completed!"
    else
        echo "Warning: AppImage packaging failed, but continuing..."
    fi
else
    echo "AppImage script not found, skipping AppImage packaging..."
fi

echo "=========================================="
echo "Build Summary"
echo "=========================================="

if [ $TEST_FAILED -eq 0 ]; then
    echo "✓ All tests passed!"
    exit 0
else
    echo "✗ Some tests failed!"
    exit 1
fi