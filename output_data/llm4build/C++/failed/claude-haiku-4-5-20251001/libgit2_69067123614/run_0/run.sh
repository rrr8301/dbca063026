#!/bin/bash

set -e

# Set environment variables for sanitizer build
export CC=clang
export CFLAGS="-fsanitize=undefined,nullability -fno-sanitize-recover=undefined,nullability -fsanitize-blacklist=/home/libgit2/source/script/sanitizers.supp -fno-optimize-sibling-calls -fno-omit-frame-pointer"
export CMAKE_OPTIONS="-DCMAKE_PREFIX_PATH=/usr/local -DUSE_HTTPS=OpenSSL -DUSE_SHA1=HTTPS -DREGEX_BACKEND=pcre -DDEPRECATE_HARD=ON -DUSE_BUNDLED_ZLIB=ON -DUSE_SSH=ON"
export CMAKE_GENERATOR="Ninja"
export SKIP_SSH_TESTS=true
export SKIP_NEGOTIATE_TESTS=true
export ASAN_SYMBOLIZER_PATH=/usr/bin/llvm-symbolizer-10
export UBSAN_OPTIONS=print_stacktrace=1

cd /home/libgit2

# Run setup script if it exists
if [ -f "source/ci/setup-sanitizer-build.sh" ]; then
    echo "Running setup script..."
    bash source/ci/setup-sanitizer-build.sh
fi

# Prepare build directory
echo "Preparing build directory..."
mkdir -p build
cd build

# Run build script
echo "Building libgit2..."
if [ -f "../source/ci/build.sh" ]; then
    bash ../source/ci/build.sh
else
    # Fallback: manual build if script doesn't exist
    cmake $CMAKE_OPTIONS ..
    cmake --build . --config Release
fi

# Run tests
echo "Running tests..."
test_exit_code=0
if [ -f "../source/ci/test.sh" ]; then
    bash ../source/ci/test.sh || test_exit_code=$?
else
    # Fallback: run ctest if script doesn't exist
    ctest -V --output-on-failure || test_exit_code=$?
fi

# Ensure all tests run even if some fail
echo "Test execution completed with exit code: $test_exit_code"

exit $test_exit_code