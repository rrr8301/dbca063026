#!/bin/bash

set -e

# Clone the main repository with submodules
echo "Cloning main repository..."
git clone --recursive --depth 5 https://github.com/FreeRTOS/FreeRTOS-Kernel.git /workspace
cd /workspace

# Checkout FreeRTOS-Kernel main branch into ./FreeRTOS/Source
echo "Checking out FreeRTOS-Kernel main branch..."
git clone --depth 1 --branch main https://github.com/FreeRTOS/FreeRTOS-Kernel.git FreeRTOS/Source

# Run Unit Tests with ENABLE_SANITIZER=1
echo "Running Unit Tests with ENABLE_SANITIZER=1..."
make -C FreeRTOS/Test/CMock clean
make -C FreeRTOS/Test/CMock ENABLE_SANITIZER=1 run_col_formatted || SANITIZER_FAILED=1

# Run Unit Tests for coverage
echo "Running Unit Tests for coverage..."
make -C FreeRTOS/Test/CMock clean
make -C FreeRTOS/Test/CMock lcovhtml || COVERAGE_FAILED=1

# Generate coverage summary
echo "Generating coverage summary..."
lcov --config-file FreeRTOS/Test/CMock/lcovrc --summary FreeRTOS/Test/CMock/build/cmock_test.info > FreeRTOS/Test/CMock/build/cmock_test_summary.txt || SUMMARY_FAILED=1

# Report results
echo "Test execution completed."
if [ -n "$SANITIZER_FAILED" ]; then
    echo "WARNING: Sanitizer tests failed"
fi
if [ -n "$COVERAGE_FAILED" ]; then
    echo "WARNING: Coverage tests failed"
fi
if [ -n "$SUMMARY_FAILED" ]; then
    echo "WARNING: Coverage summary generation failed"
fi

# Exit with failure if any test failed
if [ -n "$SANITIZER_FAILED" ] || [ -n "$COVERAGE_FAILED" ] || [ -n "$SUMMARY_FAILED" ]; then
    exit 1
fi

exit 0