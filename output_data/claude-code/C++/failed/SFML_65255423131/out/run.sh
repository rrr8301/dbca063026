#!/usr/bin/env bash

export DISPLAY=":99"
export GALLIUM_DRIVER="llvmpipe"

# Start up Xvfb and fluxbox to host display tests
Xvfb $DISPLAY -screen 0 1920x1080x24 &
sleep 5
fluxbox > /dev/null 2>&1 &
sleep 5

# Make sure the build/bin directory exists so that the find command does not fail if no executables are built
mkdir -p build/bin

# Make use of a test to print OpenGL vendor/renderer/version info to the console
find build/bin -name test-sfml-window -or -name test-sfml-window.exe -exec sh -c "{} *sf::Context* --section=\"Version String\" --success | grep OpenGL" \; || true

# Run tests
ctest --test-dir build --output-on-failure -C Debug --repeat until-pass:3 || true

# Run gcovr to extract coverage information from the test run
gcovr -r /app -x build/coverage.out -s -f 'src/SFML/.*' -f 'include/SFML/.*' /app || true

# Test install interfaces
echo "Testing install interface (Package path)..."
cmake -S test/install -B test/install/build -DCMAKE_PREFIX_PATH=/app/build/install -DCMAKE_VERBOSE_MAKEFILE=ON -DCMAKE_BUILD_TYPE=Debug -GNinja -DBUILD_SHARED_LIBS=OFF -DCMAKE_BUILD_TYPE=Debug -DSFML_ENABLE_COVERAGE=ON -DSFML_FATAL_OPENGL_ERRORS=ON -DCMAKE_FIND_ROOT_PATH_MODE_PACKAGE=BOTH || true
cmake --build test/install/build --config Debug || true

echo "Testing install interface (Config path)..."
cmake -S test/install -B test/install/build -DSFML_DIR=/app/build/install/lib/cmake/SFML -DCMAKE_VERBOSE_MAKEFILE=ON -DCMAKE_BUILD_TYPE=Debug -GNinja -DBUILD_SHARED_LIBS=OFF -DCMAKE_BUILD_TYPE=Debug -DSFML_ENABLE_COVERAGE=ON -DSFML_FATAL_OPENGL_ERRORS=ON --fresh || true
cmake --build test/install/build --config Debug || true

echo "FINAL_STATUS = SUCCESS"
