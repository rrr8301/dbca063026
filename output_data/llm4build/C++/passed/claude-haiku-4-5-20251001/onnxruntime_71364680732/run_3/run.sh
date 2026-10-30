#!/bin/bash

set -e

# Print environment info
echo "=== Environment Info ==="
python --version
node --version
java -version
cmake --version
ninja --version
echo "========================"

# Set environment variables
export PATH=/workspace/build/installed/bin:$PATH
export ONNX_ML=1
export CMAKE_ARGS="-DONNX_GEN_PB_TYPE_STUBS=ON -DONNX_WERROR=OFF"

# Define build flags (simulating arm64 Debug build)
BUILD_FLAGS="--build_dir ./build \
  --skip_submodule_sync \
  --parallel \
  --use_binskim_compliant_compile_flags \
  --build_shared_lib \
  --build_nodejs \
  --build_objc \
  --build_java \
  --build_wheel \
  --enable_arm_neon_nchwc \
  --use_vcpkg \
  --use_vcpkg_ms_internal_asset_cache \
  --config Debug \
  --osx_arch arm64"

cd /workspace

# Step 1: Configure Build (build.py --update)
echo "=== Configuring Build ==="
rm -rf /workspace/build/Debug || true
python ./tools/ci_build/build.py --update $BUILD_FLAGS

# Step 2: Build (build.py --build)
echo "=== Building ==="
python ./tools/ci_build/build.py --build $BUILD_FLAGS

# Step 3: Install
echo "=== Installing ==="
rm -rf /workspace/build/installed || true
if [ -d "/workspace/build/Debug" ]; then
    cd /workspace/build/Debug
    make install DESTDIR=/workspace/build/installed
    cd /workspace
fi

# Step 4: Run Tests (build.py --test)
# Note: Tests are skipped when cross-compiling (machine != target)
# In this Docker environment, we simulate the native build scenario
echo "=== Running Tests ==="
python ./tools/ci_build/build.py --test $BUILD_FLAGS

echo "=== Build and Test Complete ==="
exit 0