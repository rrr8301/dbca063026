#!/usr/bin/env bash
set -e

# Set environment variables
export CC=gcc
export CMAKE_GENERATOR=Ninja
export CMAKE_OPTIONS="-DUSE_HTTPS=OpenSSL -DREGEX_BACKEND=builtin -DDEBUG_LEAK_CHECKER=valgrind -DUSE_GSSAPI=ON -DUSE_SSH=libssh2 -DDEBUG_STRICT_ALLOC=ON -DDEBUG_STRICT_OPEN=ON"
export CMAKE_GLOBAL_OPTIONS="-DDEPRECATE_HARD=ON -DENABLE_WERROR=ON -DBUILD_EXAMPLES=ON -DBUILD_FUZZERS=ON -DUSE_STANDALONE_FUZZERS=ON"

cd /app

# Create build directory
mkdir -p build
cd build

# Run build
echo "==== Building libgit2 ===="
../ci/build.sh
BUILD_STATUS=$?

if [ $BUILD_STATUS -ne 0 ]; then
    echo "Build failed with exit code: $BUILD_STATUS"
    echo "FINAL_STATUS = FAIL"
    exit 1
fi

# Run tests
echo ""
echo "==== Running tests ===="
../ci/test.sh || true
TEST_STATUS=$?

if [ $TEST_STATUS -ne 0 ]; then
    echo "Some tests failed with exit code: $TEST_STATUS"
    echo "FINAL_STATUS = FAIL"
    exit 1
fi

echo "FINAL_STATUS = SUCCESS"
exit 0
