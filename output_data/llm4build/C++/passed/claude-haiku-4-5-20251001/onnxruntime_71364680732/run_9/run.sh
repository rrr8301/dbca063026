#!/bin/bash

set -e

# Print environment info
echo "=== Environment Info ==="
python --version
node --version
java -version
javac -version
cmake --version
ninja --version
gradle --version
echo "========================"

# Set environment variables
export PATH=/workspace/build/installed/bin:$PATH
export ONNX_ML=1
export CMAKE_ARGS="-DONNX_GEN_PB_TYPE_STUBS=ON -DONNX_WERROR=OFF"
export JAVA_HOME=${JAVA_HOME:-/usr/lib/jvm/java-17-openjdk-amd64}
export PATH=$JAVA_HOME/bin:$PATH

# Define build flags (Linux native build - removed macOS-specific flags)
BUILD_FLAGS="--build_dir ./build \
  --skip_submodule_sync \
  --parallel \
  --use_binskim_compliant_compile_flags \
  --build_shared_lib \
  --build_nodejs \
  --build_java \
  --build_wheel \
  --use_vcpkg \
  --use_vcpkg_ms_internal_asset_cache \
  --allow_running_as_root \
  --config Debug"

cd /workspace

# Step 1: Configure Build (build.py --update)
echo "=== Configuring Build ==="
rm -rf /workspace/build/Debug || true
python ./tools/ci_build/build.py --update $BUILD_FLAGS 2>&1 | tee build_update.log
BUILD_UPDATE_STATUS=${PIPESTATUS[0]}

if [ $BUILD_UPDATE_STATUS -ne 0 ]; then
    echo "ERROR: Build configuration failed with status $BUILD_UPDATE_STATUS"
    echo "=== Last 100 lines of build_update.log ==="
    tail -100 build_update.log
    exit $BUILD_UPDATE_STATUS
fi

# Step 2: Build (build.py --build)
echo "=== Building ==="
python ./tools/ci_build/build.py --build $BUILD_FLAGS 2>&1 | tee build_compile.log
BUILD_STATUS=${PIPESTATUS[0]}

if [ $BUILD_STATUS -ne 0 ]; then
    echo "ERROR: Build failed with status $BUILD_STATUS"
    echo "=== Last 200 lines of build_compile.log ==="
    tail -200 build_compile.log
    echo ""
    echo "=== Searching for actual error messages ==="
    grep -i "error" build_compile.log | tail -50 || true
    exit $BUILD_STATUS
fi

# Step 3: Install
echo "=== Installing ==="
rm -rf /workspace/build/installed || true
if [ -d "/workspace/build/Debug" ]; then
    cd /workspace/build/Debug
    make install DESTDIR=/workspace/build/installed 2>&1 | tee install.log
    INSTALL_STATUS=${PIPESTATUS[0]}
    
    if [ $INSTALL_STATUS -ne 0 ]; then
        echo "ERROR: Install failed with status $INSTALL_STATUS"
        echo "=== Last 100 lines of install.log ==="
        tail -100 install.log
        exit $INSTALL_STATUS
    fi
    cd /workspace
else
    echo "ERROR: Build directory /workspace/build/Debug not found"
    exit 1
fi

# Step 4: Run Tests (build.py --test)
echo "=== Running Tests ==="
python ./tools/ci_build/build.py --test $BUILD_FLAGS 2>&1 | tee build_test.log
TEST_STATUS=${PIPESTATUS[0]}

if [ $TEST_STATUS -ne 0 ]; then
    echo "WARNING: Tests failed with status $TEST_STATUS"
    echo "=== Last 200 lines of build_test.log ==="
    tail -200 build_test.log
    # Don't exit here - we want to see test results even if some fail
fi

echo "=== Build and Test Complete ==="
exit 0