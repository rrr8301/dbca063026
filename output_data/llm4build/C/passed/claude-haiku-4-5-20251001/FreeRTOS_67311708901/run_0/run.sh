#!/bin/bash

set -e

# Clone the main repository with recursive submodules
git clone --recursive --depth 5 https://github.com/FreeRTOS/FreeRTOS-Kernel.git /workspace/repo
cd /workspace/repo

# Checkout the main branch from the FreeRTOS-Kernel repository into ./FreeRTOS/Source
git clone --depth 1 --branch main https://github.com/FreeRTOS/FreeRTOS-Kernel.git ./FreeRTOS/Source

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