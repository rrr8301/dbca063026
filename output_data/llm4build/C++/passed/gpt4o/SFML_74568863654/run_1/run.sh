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
cmake .. -DCMAKE_VERBOSE_MAKEFILE=ON -DSFML_RUN_IPV4_LINK_TESTS=ON -DSFML_RUN_IPV4_INTERNET_TESTS=ON -DSFML_RUN_IPV6_LINK_TESTS=ON -DSFML_NETWORK_TESTS_MAX_FDS=1028 -GNinja -DBUILD_SHARED_LIBS=ON -DCMAKE_BUILD_TYPE=Debug -DSFML_ENABLE_COVERAGE=ON -DSFML_FATAL_OPENGL_ERRORS=ON

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
ctest --output-on-failure -C Debug --repeat until-pass:3
if [ "$matrix_type_name" == "Debug" ]; then
  gcovr -r $GITHUB_WORKSPACE -x coverage.out -s -f 'src/SFML/.*' -f 'include/SFML/.*' $GITHUB_WORKSPACE
fi
ls

# Test Install Interface (Package path)
cmake -S ../test/install -B ../test/install/build -DCMAKE_PREFIX_PATH=$GITHUB_WORKSPACE/build/install -DCMAKE_VERBOSE_MAKEFILE=ON -DCMAKE_BUILD_TYPE=Debug -GNinja -DBUILD_SHARED_LIBS=ON -DCMAKE_BUILD_TYPE=Debug -DSFML_ENABLE_COVERAGE=ON -DSFML_FATAL_OPENGL_ERRORS=ON -DCMAKE_FIND_ROOT_PATH_MODE_PACKAGE=BOTH
cmake --build ../test/install/build --config Debug

# Test Install Interface (Config path)
cmake -S ../test/install -B ../test/install/build -DSFML_DIR=$GITHUB_WORKSPACE/build/install/lib/cmake/SFML -DCMAKE_VERBOSE_MAKEFILE=ON -DCMAKE_BUILD_TYPE=Debug -GNinja -DBUILD_SHARED_LIBS=ON -DCMAKE_BUILD_TYPE=Debug -DSFML_ENABLE_COVERAGE=ON -DSFML_FATAL_OPENGL_ERRORS=ON --fresh
cmake --build ../test/install/build --config Debug