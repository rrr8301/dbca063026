#!/bin/bash

set -e

# Determine the correct llvm-symbolizer path
LLVM_SYMBOLIZER_PATH=""
if [ -f "/usr/bin/llvm-symbolizer" ]; then
    LLVM_SYMBOLIZER_PATH="/usr/bin/llvm-symbolizer"
elif [ -f "/usr/bin/llvm-symbolizer-18" ]; then
    LLVM_SYMBOLIZER_PATH="/usr/bin/llvm-symbolizer-18"
elif [ -f "/usr/bin/llvm-symbolizer-10" ]; then
    LLVM_SYMBOLIZER_PATH="/usr/bin/llvm-symbolizer-10"
else
    # Find any available llvm-symbolizer
    LLVM_SYMBOLIZER_PATH=$(find /usr/bin -name "llvm-symbolizer*" -type f | head -1)
fi

# Set environment variables for sanitizer build
export CC=clang
export CFLAGS="-fsanitize=undefined,nullability -fno-sanitize-recover=undefined,nullability -fsanitize-blacklist=/home/libgit2/source/script/sanitizers.supp -fno-optimize-sibling-calls -fno-omit-frame-pointer"
export LDFLAGS="-fsanitize=undefined,nullability"
export CMAKE_OPTIONS="-DCMAKE_PREFIX_PATH=/usr/local -DUSE_HTTPS=OpenSSL -DUSE_SHA1=HTTPS -DREGEX_BACKEND=pcre -DDEPRECATE_HARD=ON -DUSE_BUNDLED_ZLIB=ON -DUSE_SSH=ON"
export CMAKE_GENERATOR="Ninja"
export SKIP_SSH_TESTS=true
export SKIP_NEGOTIATE_TESTS=true
export ASAN_SYMBOLIZER_PATH="$LLVM_SYMBOLIZER_PATH"
export UBSAN_OPTIONS=print_stacktrace=1

cd /home/libgit2

# Run setup script if it exists
if [ -f "source/ci/setup-sanitizer-build.sh" ]; then
    echo "Running setup script..."
    # In container environment, we already have root privileges, so no sudo needed
    # Create a wrapper that removes sudo calls for container execution
    bash -c "$(sed 's/^[[:space:]]*sudo[[:space:]]\+//' source/ci/setup-sanitizer-build.sh)"
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