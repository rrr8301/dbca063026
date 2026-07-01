#!/usr/bin/env bash
set -o pipefail

cd /app/build

# Build the project
echo "==== Building taglib ===="
cmake --build . --config Release --parallel
BUILD_STATUS=$?

if [ $BUILD_STATUS -ne 0 ]; then
    echo "FINAL_STATUS = FAIL"
    exit 1
fi

# Run tests
echo "==== Running tests ===="
ctest -C Release -V --no-tests=error
TEST_STATUS=$?

if [ $TEST_STATUS -eq 0 ]; then
    echo "FINAL_STATUS = SUCCESS"
else
    echo "FINAL_STATUS = FAIL"
fi

exit $TEST_STATUS
