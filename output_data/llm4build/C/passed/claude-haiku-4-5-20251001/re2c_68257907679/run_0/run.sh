#!/bin/bash

set -e

# Enable error handling: continue on test failures but track exit status
TEST_FAILED=0

echo "=== Starting re2c CI Build and Test ==="

# Step 1: Generate configure script
echo "=== Generating ./configure ==="
./autogen.sh

# Step 2: Fast Configure (minimal build)
echo "=== Fast Configure ==="
./configure \
    --disable-dlang \
    --disable-golang \
    --disable-haskell \
    --disable-java \
    --disable-js \
    --disable-ocaml \
    --disable-python \
    --disable-rust \
    --disable-swift \
    --disable-vlang \
    --disable-zig \
    --prefix="$(pwd)/install"

# Step 3: Fast Build
echo "=== Fast Build ==="
make -j"$(nproc)"

# Step 4: Fast Install
echo "=== Fast Install ==="
make -j"$(nproc)" install

# Step 5: Fast Clean
echo "=== Fast Clean ==="
make -j"$(nproc)" distclean

# Step 6: Minimal Install Test
echo "=== Minimal Install Test ==="
./install/bin/re2c --version

# Step 7: Setup build directory for full build
echo "=== Setting up full build directory ==="
BUILD_DIR="$(pwd)/.build/linux-gcc-ootree-full"
mkdir -p "$BUILD_DIR"

# Step 8: Full Configure (out-of-tree)
echo "=== Full Configure ==="
cd "$BUILD_DIR"
"$GITHUB_WORKSPACE/configure" \
    --prefix="$BUILD_DIR/full-install" \
    --enable-libs \
    --enable-parsers \
    --enable-lexers \
    --enable-docs \
    --enable-debug \
    RE2C_FOR_BUILD="$GITHUB_WORKSPACE/install/bin/re2c"

# Step 9: Full Build
echo "=== Full Build ==="
find "$GITHUB_WORKSPACE/src" -name '*.re' -exec touch {} \;
make -j"$(nproc)"

# Step 10: Run Main Test Suite
echo "=== Running Main Test Suite ==="
if bash -c "ulimit -s 256; make check -j$(nproc)"; then
    echo "Main test suite passed"
else
    echo "Main test suite failed"
    TEST_FAILED=1
fi

# Step 11: Run Skeleton Tests
echo "=== Running Skeleton Tests ==="
if python3 run_tests.py --skeleton; then
    echo "Skeleton tests passed"
else
    echo "Skeleton tests failed"
    TEST_FAILED=1
fi

# Step 12: Full Install
echo "=== Full Install ==="
make -j"$(nproc)" install

echo "=== Build and Test Complete ==="

# Exit with failure status if any tests failed
if [ $TEST_FAILED -ne 0 ]; then
    echo "Some tests failed. See output above for details."
    exit 1
fi

exit 0