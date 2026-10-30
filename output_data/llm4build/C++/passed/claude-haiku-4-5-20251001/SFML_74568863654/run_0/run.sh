#!/bin/bash

set -e

# Clone the repository (assuming it's passed as an argument or we're already in the repo)
# If running in a pre-cloned repo, this step can be skipped
if [ ! -f "CMakeLists.txt" ]; then
    echo "Error: CMakeLists.txt not found. Repository must be cloned first."
    exit 1
fi

# Extract CLANG_VERSION
CLANG_VERSION=$(clang++ --version | sed -n 's/.*version \([0-9]\+\)\..*/\1/p')
echo "CLANG_VERSION=$CLANG_VERSION"

# Configure CMake
echo "Configuring CMake..."
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
echo "Building..."
cmake --build build --config Debug --target install

# Prepare Test - Start X11 display server and window manager
echo "Preparing test environment..."
Xvfb $DISPLAY -screen 0 1920x1080x24 &
XVFB_PID=$!
sleep 5

fluxbox > /dev/null 2>&1 &
FLUXBOX_PID=$!
sleep 5

# Verify OpenGL context
mkdir -p build/bin
find build/bin -name test-sfml-window -o -name test-sfml-window.exe | while read test_exe; do
    if [ -f "$test_exe" ]; then
        "$test_exe" *sf::Context* --section="Version String" --success | grep OpenGL || true
    fi
done

# Run tests
echo "Running tests..."
ctest --test-dir build --output-on-failure -C Debug --repeat until-pass:3

# Generate coverage report
echo "Generating coverage report..."
if [ "Debug" == "Debug" ]; then
    gcovr -r /workspace -x build/coverage.out -s -f 'src/SFML/.*' -f 'include/SFML/.*' /workspace
fi

# List build directory
ls build/

# Test Install Interface (Package path)
echo "Testing install interface (Package path)..."
cmake -S test/install -B test/install/build \
    -DCMAKE_PREFIX_PATH=/workspace/build/install \
    -DCMAKE_VERBOSE_MAKEFILE=ON \
    -DCMAKE_BUILD_TYPE=Debug \
    -GNinja \
    -DBUILD_SHARED_LIBS=ON \
    -DSFML_ENABLE_COVERAGE=ON \
    -DSFML_FATAL_OPENGL_ERRORS=ON \
    -DCMAKE_FIND_ROOT_PATH_MODE_PACKAGE=BOTH
cmake --build test/install/build --config Debug

# Test Install Interface (Config path)
echo "Testing install interface (Config path)..."
cmake -S test/install -B test/install/build \
    -DSFML_DIR=/workspace/build/install/lib/cmake/SFML \
    -DCMAKE_VERBOSE_MAKEFILE=ON \
    -DCMAKE_BUILD_TYPE=Debug \
    -GNinja \
    -DBUILD_SHARED_LIBS=ON \
    -DSFML_ENABLE_COVERAGE=ON \
    -DSFML_FATAL_OPENGL_ERRORS=ON \
    --fresh
cmake --build test/install/build --config Debug

# Cleanup
kill $XVFB_PID 2>/dev/null || true
kill $FLUXBOX_PID 2>/dev/null || true

echo "All tests completed successfully!"