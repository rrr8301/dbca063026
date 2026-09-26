#!/bin/bash

set -e

# Configuration from matrix
EVENT_MATRIX="${EVENT_MATRIX:-DISABLE_THREAD_SUPPORT}"
RELEASE="${RELEASE:-14.1}"

# Set CMake options based on EVENT_MATRIX
if [ "$EVENT_MATRIX" = "DISABLE_THREAD_SUPPORT" ]; then
    EVENT_CMAKE_OPTIONS="-DEVENT__DISABLE_THREAD_SUPPORT=ON"
else
    EVENT_CMAKE_OPTIONS=""
fi

# Build
mkdir -p build
cd build
echo "[cmake]: cmake .. $EVENT_CMAKE_OPTIONS"
cmake .. $EVENT_CMAKE_OPTIONS || (rm -rf * && cmake .. $EVENT_CMAKE_OPTIONS)
cmake --build .

# Test with retry logic (max 5 attempts, 60 minute timeout)
MAX_ATTEMPTS=5
TIMEOUT_MINUTES=60
ATTEMPT=1

while [ $ATTEMPT -le $MAX_ATTEMPTS ]; do
    echo "Test attempt $ATTEMPT of $MAX_ATTEMPTS"
    
    # Set test environment variables
    JOBS=1
    export CTEST_PARALLEL_LEVEL=$JOBS
    export CTEST_OUTPUT_ON_FAILURE=1
    
    # Run tests
    if cmake --build . --target verify; then
        echo "Tests passed on attempt $ATTEMPT"
        exit 0
    else
        TEST_EXIT_CODE=$?
        if [ $ATTEMPT -lt $MAX_ATTEMPTS ]; then
            echo "Tests failed on attempt $ATTEMPT, retrying..."
            ATTEMPT=$((ATTEMPT + 1))
            sleep 5
        else
            echo "Tests failed after $MAX_ATTEMPTS attempts"
            exit $TEST_EXIT_CODE
        fi
    fi
done