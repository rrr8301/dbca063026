#!/bin/bash

set -e

cd /workspace

# Assume the current repository is already checked out in /workspace
# If FreeRTOS/Source doesn't exist, clone the FreeRTOS-Kernel repository
if [ ! -d "FreeRTOS/Source" ]; then
    mkdir -p FreeRTOS
    git clone --depth 1 --branch main https://github.com/FreeRTOS/FreeRTOS-Kernel.git ./FreeRTOS/Source
fi

# Verify that FreeRTOS/Test/CMock exists (should come from the checked-out repository)
if [ ! -d "FreeRTOS/Test/CMock" ]; then
    echo "Error: FreeRTOS/Test/CMock directory not found!"
    echo "This directory should be part of the repository being tested."
    exit 1
fi

# Run Unit Tests with ENABLE_SANITIZER=1
echo "Running Unit Tests with ENABLE_SANITIZER=1..."
make -C FreeRTOS/Test/CMock clean
make -C FreeRTOS/Test/CMock ENABLE_SANITIZER=1 run_col_formatted

# Run Unit Tests for coverage
echo "Running Unit Tests for coverage..."
make -C FreeRTOS/Test/CMock clean
make -C FreeRTOS/Test/CMock lcovhtml
lcov --config-file FreeRTOS/Test/CMock/lcovrc --summary FreeRTOS/Test/CMock/build/cmock_test.info > FreeRTOS/Test/CMock/build/cmock_test_summary.txt

echo "All tests completed successfully!"