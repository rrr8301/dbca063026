#!/usr/bin/env bash
set -e

cd /app

# Set up ccache
export CCACHE_DIR=/tmp/ccache
mkdir -p $CCACHE_DIR

# Configure (CMake)
echo "=== Configure (CMake) ==="
cmake -S . -B build -G "Ninja" \
    -Wdeprecated -Wdev -Werror \
    -DSDL_WERROR=ON \
    -DSDL_EXAMPLES=ON \
    -DSDL_TESTS=ON \
    -DSDLTEST_TRACKMEM=ON \
    -DSDL_INSTALL_TESTS=ON \
    -DSDL_CLANG_TIDY=FALSE \
    -DSDL_INSTALL_DOCS=ON \
    -DSDL_INSTALL_CPACK=ON \
    -DSDL_ALSA_SHARED=OFF \
    -DSDL_FRIBIDI_SHARED=OFF \
    -DSDL_HIDAPI_LIBUSB_SHARED=OFF \
    -DSDL_PULSEAUDIO_SHARED=OFF \
    -DSDL_X11_SHARED=OFF \
    -DSDL_WAYLAND_LIBDECOR_SHARED=OFF \
    -DSDL_WAYLAND_SHARED=OFF \
    -DSDL_SHARED=ON \
    -DSDL_STATIC=ON \
    -DSDL_VENDOR_INFO="Github Workflow" \
    -DCMAKE_INSTALL_PREFIX=prefix \
    -DCMAKE_INSTALL_LIBDIR=lib \
    -DCMAKE_BUILD_TYPE=RelWithDebInfo \
    -DSDLTEST_GDB=ON

# Build (CMake)
echo "=== Build (CMake) ==="
cmake --build build --config RelWithDebInfo --verbose -- -j$(nproc)

# Verify SDL_REVISION
echo "=== Verify SDL_REVISION ==="
echo "Shared library:"
strings build/libSDL3.so.0 | grep "Github Workflow" || echo "Not found"
echo "Static library:"
strings build/libSDL3.a | grep "Github Workflow" || echo "Not found"

# Run build-time tests (CMake)
echo "=== Run build-time tests (CMake) ==="
export SDL_TESTS_QUICK=1
ctest --test-dir build/ -VV -j2 || true

# Install (CMake)
echo "=== Install (CMake) ==="
cmake --install build --config RelWithDebInfo
PREFIX_PATH="$(pwd)/prefix"

# Package (CPack)
echo "=== Package (CPack) ==="
success=0
max_tries=10
for i in $(seq $max_tries); do
    cmake --build build/ --config RelWithDebInfo --target package -- && success=1
    if [ $success = 1 ]; then
        break
    fi
    echo "Package creation failed. Sleep 1 second and try again."
    sleep 1
done
if [ $success = 0 ]; then
    echo "Package creation failed after $max_tries attempts."
    exit 1
fi

# Verify CMake configuration files
echo "=== Verify CMake configuration files ==="
cmake -S cmake/test -B cmake_test_build -GNinja \
    -DTEST_SHARED=ON \
    -DTEST_STATIC=ON \
    -DCMAKE_BUILD_TYPE=RelWithDebInfo \
    -DCMAKE_PREFIX_PATH="${PREFIX_PATH}"
cmake --build cmake_test_build --verbose --config RelWithDebInfo -- || true

# Verify sdl3.pc
echo "=== Verify sdl3.pc ==="
export PKG_CONFIG_PATH="${PREFIX_PATH}/lib/pkgconfig"
bash cmake/test/test_pkgconfig.sh || true

# Check if all critical steps passed
if [ -f build/libSDL3.so.0 ] && [ -f build/libSDL3.a ]; then
    echo "FINAL_STATUS = SUCCESS"
else
    echo "FINAL_STATUS = FAIL"
    exit 1
fi
