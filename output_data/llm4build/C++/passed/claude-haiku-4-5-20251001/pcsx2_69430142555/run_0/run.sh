#!/bin/bash

set -e

# Enable error handling: continue on test failures but track them
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
echo "Step 1: Prepare Build Environment"
echo "=========================================="

# Verify clang-17 is available
clang-17 --version
clang++-17 --version
ninja --version
cmake --version

echo "=========================================="
echo "Step 2: Build Dependencies"
echo "=========================================="

# Build dependencies (FFmpeg, Qt, etc.)
# This script is provided in the repository
if [ ! -d "$HOME/deps" ]; then
    echo "Building dependencies..."
    BUILD_FFMPEG=1 ./.github/workflows/scripts/linux/build-dependencies-qt.sh "$HOME/deps"
else
    echo "Dependencies already built, skipping..."
fi

echo "=========================================="
echo "Step 3: Download Patches"
echo "=========================================="

# Download patches from GitHub releases
cd bin/resources
if [ ! -f "patches.zip" ]; then
    echo "Downloading patches..."
    aria2c -Z "https://github.com/PCSX2/pcsx2_patches/releases/latest/download/patches.zip" || {
        echo "Warning: Failed to download patches, continuing without them..."
    }
else
    echo "Patches already downloaded, skipping..."
fi
cd /workspace

echo "=========================================="
echo "Step 4: Generate CMake Configuration"
echo "=========================================="

# Generate CMake build configuration
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
echo "Step 5: Build PCSX2"
echo "=========================================="

cd build

# Prepare ccache
echo "Initializing ccache..."
ccache -p
ccache -z

# Build with Ninja
echo "Building PCSX2..."
ninja

# Report ccache statistics
echo "ccache statistics:"
ccache -s

cd /workspace

echo "=========================================="
echo "Step 6: Run Unit Tests"
echo "=========================================="

cd build

echo "Running unit tests..."
if ninja unittests; then
    echo "✓ Unit tests passed"
else
    echo "✗ Unit tests failed"
    TEST_FAILED=1
fi

cd /workspace

echo "=========================================="
echo "Step 7: Package AppImage (Optional)"
echo "=========================================="

# AppImage packaging is optional and requires additional setup
# Uncomment below if AppImage packaging is needed
# if [ -f "./.github/workflows/scripts/linux/appimage-qt.sh" ]; then
#     echo "Packaging AppImage..."
#     ARTIFACT_NAME="PCSX2-linux-Qt-x64-appimage"
#     ./.github/workflows/scripts/linux/appimage-qt.sh "$(realpath .)" "$(realpath ./build)" "$HOME/deps" "$ARTIFACT_NAME"
#     mkdir -p "$GITHUB_WORKSPACE"/ci-artifacts/
#     mv "${ARTIFACT_NAME}.AppImage" "$GITHUB_WORKSPACE"/ci-artifacts/ || echo "Warning: AppImage packaging failed"
# fi

echo "=========================================="
echo "Build Summary"
echo "=========================================="

if [ $TEST_FAILED -eq 0 ]; then
    echo "✓ All tests passed successfully"
    exit 0
else
    echo "✗ Some tests failed"
    exit 1
fi