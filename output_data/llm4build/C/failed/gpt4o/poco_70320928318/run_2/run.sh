#!/bin/bash

# Navigate to the workspace
cd /workspace

# Configure the build with CMake
cmake -S. -Bcmake-build -GNinja -DENABLE_PDF=OFF -DENABLE_TESTS=ON

# Run tests with ctest, retrying on failure
attempts=0
max_attempts=3
while [ $attempts -lt $max_attempts ]; do
    ((attempts++))
    cd cmake-build
    ctest --output-on-failure
    exit_code=$?
    if [ $exit_code -eq 0 ]; then
        break
    fi
    echo "Test attempt $attempts failed. Retrying..."
    sleep 10
done

exit $exit_code