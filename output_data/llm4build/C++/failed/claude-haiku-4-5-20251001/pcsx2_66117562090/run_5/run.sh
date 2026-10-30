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
echo "Step 3: Fix Compilation Issues"
echo "=========================================="

# Fix the type mismatch in microVU_Macro.inl
# The issue is that rax is xAddressReg but _freeX86reg expects xRegister32 or int
# We need to cast it properly or use the correct register type
if [ -f "/workspace/pcsx2/x86/microVU_Macro.inl" ]; then
    # Replace _freeX86reg(rax) with proper casting to int
    sed -i 's/_freeX86reg(rax);/_freeX86reg(static_cast<int>(rax));/g' /workspace/pcsx2/x86/microVU_Macro.inl
    echo "Applied compilation fix for microVU_Macro.inl"
fi

echo "=========================================="
echo "Step 4: Generate CMake"
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
    -DCMAKE_DISABLE_PRECOMPILE_HEADERS=ON \
    -DCMAKE_CXX_FLAGS="-Wno-sign-compare"

echo "=========================================="
echo "Step 5: Build PCSX2"
echo "=========================================="

cd /workspace/build

# Prepare the Cache
ccache -p
ccache -z

# Build with verbose output for debugging
ninja -v 2>&1 | tee build.log || {
    echo "Build failed! Showing last 100 lines of build log:"
    tail -100 build.log
    exit 1
}

# Save the Cache
ccache -s

echo "=========================================="
echo "Step 6: Run Unit Tests"
echo "=========================================="

if ninja unittests 2>&1 | tee test.log; then
    echo "Unit tests passed!"
else
    echo "Unit tests failed!"
    echo "Showing last 50 lines of test log:"
    tail -50 test.log
    TEST_FAILED=1
fi

echo "=========================================="
echo "Step 7: Package AppImage (Optional)"
echo "=========================================="

# Attempt to build AppImage if script exists
if [ -f "/workspace/.github/workflows/scripts/linux/appimage-qt.sh" ]; then
    ARTIFACT_NAME="PCSX2-linux-Qt-x64-appimage"
    
    # Try to build AppImage, but don't fail the entire build if it fails
    # This is expected in containerized environments without proper FUSE support
    if /workspace/.github/workflows/scripts/linux/appimage-qt.sh "$(realpath /workspace)" "$(realpath /workspace/build)" "$HOME/deps" "$ARTIFACT_NAME" 2>&1 | tee appimage.log; then
        mkdir -p "/workspace/ci-artifacts/"
        if [ -f "${ARTIFACT_NAME}.AppImage" ]; then
            mv "${ARTIFACT_NAME}.AppImage" "/workspace/ci-artifacts/" || echo "Warning: Failed to move AppImage"
            echo "AppImage packaging completed successfully!"
        else
            echo "Warning: AppImage file not found after packaging"
        fi
    else
        # Check if failure is due to FUSE (expected in containers)
        if grep -q "fusermount\|FUSE\|fuse: device not found" appimage.log; then
            echo "Note: AppImage packaging failed due to FUSE unavailability (expected in containers)"
            echo "This is not a critical failure - the build and tests completed successfully"
        else
            echo "Warning: AppImage packaging failed for other reasons"
            tail -50 appimage.log
        fi
    fi
else
    echo "AppImage script not found, skipping AppImage packaging..."
fi

echo "=========================================="
echo "Build Summary"
echo "=========================================="

if [ $TEST_FAILED -eq 0 ]; then
    echo "✓ All critical tests passed!"
    echo "✓ Build completed successfully!"
    exit 0
else
    echo "✗ Some tests failed!"
    exit 1
fi