#!/bin/bash

# Activate environment variables
export DISPLAY=":99"
export GALLIUM_DRIVER="llvmpipe"
export ANDROID_NDK_VERSION="26.1.10909125"
export CMAKE_CXX_COMPILER_LAUNCHER="ccache"

# Create build directory
mkdir -p build

# Install project dependencies
cmake --preset dev -DCMAKE_VERBOSE_MAKEFILE=ON -GNinja -DBUILD_SHARED_LIBS=OFF -DCMAKE_BUILD_TYPE=Debug -DSFML_ENABLE_COVERAGE=ON -DSFML_FATAL_OPENGL_ERRORS=ON

# Build the project
cmake --build build --config Debug --target install

# Prepare test environment
set -e
Xvfb $DISPLAY -screen 0 1920x1080x24 &
sleep 5
fluxbox > /dev/null 2>&1 &
sleep 5
mkdir -p build/bin
find build/bin -name test-sfml-window -or -name test-sfml-window.exe -exec sh -c "{} *sf::Context* --section=\"Version String\" --success | grep OpenGL" \;

# Run tests
ctest --test-dir build --output-on-failure -C Debug --repeat until-pass:3

# Run gcovr for coverage
gcovr -r /app -x build/coverage.out -s -f 'src/SFML/.*' -f 'include/SFML/.*' /app

# List build directory contents
ls build/