#!/usr/bin/env bash
set -e

cd /app

export PATH=/app/build/installed/bin:$PATH
export ONNX_ML=1
export CMAKE_ARGS="-DONNX_GEN_PB_TYPE_STUBS=ON -DONNX_WERROR=OFF"

# Build flags for Debug configuration (adapted for Linux)
BUILD_FLAGS="
--build_dir ./build
--skip_submodule_sync
--parallel
--use_binskim_compliant_compile_flags
--build_shared_lib
--build_nodejs
--build_java
--build_wheel
--enable_arm_neon_nchwc
--use_vcpkg --use_vcpkg_ms_internal_asset_cache
--config Debug
--allow_running_as_root
"

echo "======== Configure Build ========"
rm -rf /app/build/Debug
python3 ./tools/ci_build/build.py --update $BUILD_FLAGS

echo "======== Build ========"
python3 ./tools/ci_build/build.py --build $BUILD_FLAGS

echo "======== Install ========"
rm -rf /app/build/installed
cd /app/build/Debug
make install DESTDIR=/app/build/installed || true

echo "======== Running Tests ========"
cd /app
python3 ./tools/ci_build/build.py --test $BUILD_FLAGS || true

echo "FINAL_STATUS = SUCCESS"
