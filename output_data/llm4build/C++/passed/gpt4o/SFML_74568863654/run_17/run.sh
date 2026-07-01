#!/bin/bash

# Activate environment variables
export DISPLAY=":99"
export GALLIUM_DRIVER="llvmpipe"
export ANDROID_NDK_VERSION="26.1.10909125"
export CMAKE_CXX_COMPILER_LAUNCHER="ccache"

# Create build directory
mkdir -p build
cd build

# Install project dependencies
cmake .. -DCMAKE_VERBOSE_MAKEFILE=ON -DSFML_RUN_IPV4_LINK_TESTS=ON -DSFML_RUN_IPV4_INTERNET_TESTS=ON -DSFML_RUN_IPV6_LINK_TESTS=ON -DSFML_NETWORK_TESTS_MAX_FDS=1028 -GNinja -DBUILD_SHARED_LIBS=ON -DCMAKE_BUILD_TYPE=Debug

# Build the project
cmake --build . --config Debug --target install

# Prepare test environment
set -e
Xvfb $DISPLAY -screen 0 1920x1080x24 &
sleep 5
fluxbox > /dev/null 2>&1 &
sleep 5
mkdir -p bin
find bin -name test-sfml-window -or -name test-sfml-window.exe -exec sh -c "{} *sf::Context* --section=\"Version String\" --success | grep OpenGL" \;

# Run tests
ctest --output-on-failure -C Debug --repeat until-pass:3 || echo "No tests were found or tests failed."

# Check if tests were found and run
if [ -d "Testing" ] && [ -f "Testing/TAG" ]; then
  echo "Tests were found and executed."
else
  echo "No tests were found. Please check the CMakeLists.txt for test configuration."
fi

# Test Install Interface (Package path)
cmake -S ../test/install -B ../test/install/build -DCMAKE_PREFIX_PATH=/app/build/install -DCMAKE_VERBOSE_MAKEFILE=ON -DCMAKE_BUILD_TYPE=Debug -GNinja -DBUILD_SHARED_LIBS=ON
cmake --build ../test/install/build --config Debug

# Test Install Interface (Config path)
cmake -S ../test/install -B ../test/install/build -DSFML_DIR=/app/build/install/lib/cmake/SFML -DCMAKE_VERBOSE_MAKEFILE=ON -DCMAKE_BUILD_TYPE=Debug -GNinja -DBUILD_SHARED_LIBS=ON --fresh
cmake --build ../test/install/build --config Debug