#!/bin/bash

set -e

# Activate environment variables
export PATH=/app/build/installed/bin:$PATH
export ONNX_ML=1
export CMAKE_ARGS="-DONNX_GEN_PB_TYPE_STUBS=ON -DONNX_WERROR=OFF"

# Configure Build
rm -rf /app/build/Debug
python3.13 ./tools/ci_build/build.py --update --build_dir ./build --skip_submodule_sync --parallel --use_binskim_compliant_compile_flags --build_shared_lib --build_nodejs --build_objc --build_java --build_wheel --enable_arm_neon_nchwc --use_vcpkg --use_vcpkg_ms_internal_asset_cache --config Debug --allow_running_as_root

# Build
python3.13 ./tools/ci_build/build.py --build --build_dir ./build --skip_submodule_sync --parallel --use_binskim_compliant_compile_flags --build_shared_lib --build_nodejs --build_objc --build_java --build_wheel --enable_arm_neon_nchwc --use_vcpkg --use_vcpkg_ms_internal_asset_cache --config Debug --allow_running_as_root

# Install
rm -rf /app/build/installed
cd /app/build/Debug
make install DESTDIR=/app/build/installed

# Run Tests
python3.13 ./tools/ci_build/build.py --test --build_dir ./build --skip_submodule_sync --parallel --use_binskim_compliant_compile_flags --build_shared_lib --build_nodejs --build_objc --build_java --build_wheel --enable_arm_neon_nchwc --use_vcpkg --use_vcpkg_ms_internal_asset_cache --config Debug --allow_running_as_root || true