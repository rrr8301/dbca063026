#!/bin/bash

set -e

# Set environment variables
export DISPLAY=":99"
export GALLIUM_DRIVER=llvmpipe
export CMAKE_CXX_COMPILER_LAUNCHER=ccache

# Start Xvfb virtual display
Xvfb $DISPLAY -screen 0 1920x1080x24 &
sleep 5

# Start window manager
fluxbox > /dev/null 2>&1 &
sleep 5

# Configure CMake
cmake --preset dev -DCMAKE_VERBOSE_MAKEFILE=ON -GNinja -DBUILD_SHARED_LIBS=OFF -DCMAKE_BUILD_TYPE=Debug -DSFML_ENABLE_COVERAGE=ON -DSFML_FATAL_OPENGL_ERRORS=ON

# Build
cmake --build build --config Debug --target install

# Prepare Test
mkdir -p build/bin
find build/bin -name test-sfml-window -o -name test-sfml-window.exe -exec sh -c "{} *sf::Context* --section=\"Version String\" --success | grep OpenGL" \;

# Test (Linux/macOS/MinGW)
ctest --test-dir build --output-on-failure -C Debug --repeat until-pass:3
gcovr -r /workspace -x build/coverage.out -s -f 'src/SFML/.*' -f 'include/SFML/.*' /workspace
ls build/

# Test Install Interface (Package path)
cmake -S test/install -B test/install/build -DCMAKE_PREFIX_PATH=/workspace/build/install -DCMAKE_VERBOSE_MAKEFILE=ON -DCMAKE_BUILD_TYPE=Debug -GNinja -DBUILD_SHARED_LIBS=OFF -DCMAKE_BUILD_TYPE=Debug -DSFML_ENABLE_COVERAGE=ON -DSFML_FATAL_OPENGL_ERRORS=ON -DCMAKE_FIND_ROOT_PATH_MODE_PACKAGE=BOTH
cmake --build test/install/build --config Debug

# Test Install Interface (Config path)
cmake -S test/install -B test/install/build -DSFML_DIR=/workspace/build/install/lib/cmake/SFML -DCMAKE_VERBOSE_MAKEFILE=ON -DCMAKE_BUILD_TYPE=Debug -GNinja -DBUILD_SHARED_LIBS=OFF -DCMAKE_BUILD_TYPE=Debug -DSFML_ENABLE_COVERAGE=ON -DSFML_FATAL_OPENGL_ERRORS=ON --fresh
cmake --build test/install/build --config Debug

echo "All tests completed successfully!"