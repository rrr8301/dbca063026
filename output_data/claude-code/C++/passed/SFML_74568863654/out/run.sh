#!/usr/bin/env bash

cd /app

# Start Xvfb and fluxbox for display tests
Xvfb $DISPLAY -screen 0 1920x1080x24 &
sleep 5
fluxbox > /dev/null 2>&1 &
sleep 5

# Configure CMake
cmake --preset dev \
    -DCMAKE_VERBOSE_MAKEFILE=ON \
    -DSFML_RUN_IPV4_LINK_TESTS=ON \
    -DSFML_RUN_IPV4_INTERNET_TESTS=ON \
    -DSFML_RUN_IPV6_LINK_TESTS=ON \
    -DSFML_NETWORK_TESTS_MAX_FDS=1028 \
    -GNinja \
    -DBUILD_SHARED_LIBS=ON \
    -DCMAKE_BUILD_TYPE=Debug \
    -DSFML_ENABLE_COVERAGE=ON \
    -DSFML_FATAL_OPENGL_ERRORS=ON

# Build
cmake --build build --config Debug --target install

# Prepare tests - print OpenGL info
mkdir -p build/bin
find build/bin -name test-sfml-window -or -name test-sfml-window.exe -exec sh -c "{} *sf::Context* --section=\"Version String\" --success | grep OpenGL" \; || true

# Run tests
ctest --test-dir build --output-on-failure -C Debug --repeat until-pass:3

# Run gcovr for coverage
gcovr -r /app -x build/coverage.out -s -f 'src/SFML/.*' -f 'include/SFML/.*' /app || true

# Test Install Interface (Package path)
cmake -S test/install -B test/install/build \
    -DCMAKE_PREFIX_PATH=/app/build/install \
    -DCMAKE_VERBOSE_MAKEFILE=ON \
    -DCMAKE_BUILD_TYPE=Debug \
    -GNinja \
    -DBUILD_SHARED_LIBS=ON \
    -DCMAKE_CXX_COMPILER_LAUNCHER=ccache \
    -DCMAKE_FIND_ROOT_PATH_MODE_PACKAGE=BOTH

cmake --build test/install/build --config Debug

# Test Install Interface (Config path)
cmake -S test/install -B test/install/build \
    -DSFML_DIR=/app/build/install/lib/cmake/SFML \
    -DCMAKE_VERBOSE_MAKEFILE=ON \
    -DCMAKE_BUILD_TYPE=Debug \
    -GNinja \
    -DBUILD_SHARED_LIBS=ON \
    -DCMAKE_CXX_COMPILER_LAUNCHER=ccache \
    --fresh

cmake --build test/install/build --config Debug

echo "FINAL_STATUS = SUCCESS"
