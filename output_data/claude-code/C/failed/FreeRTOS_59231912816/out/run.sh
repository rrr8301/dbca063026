#!/usr/bin/env bash
set -e

echo "=== Running FreeRTOS Kernel Unit Tests ==="

# Run Unit Tests with ENABLE_SANITIZER=1
echo "=== Step 1: Running Unit Tests with ENABLE_SANITIZER=1 ==="
make -C FreeRTOS/Test/CMock clean
make -C FreeRTOS/Test/CMock ENABLE_SANITIZER=1 run_col_formatted

# Run Unit Tests for coverage
echo "=== Step 2: Running Unit Tests for coverage ==="
make -C FreeRTOS/Test/CMock clean
make -C FreeRTOS/Test/CMock lcovhtml
lcov --config-file FreeRTOS/Test/CMock/lcovrc --summary FreeRTOS/Test/CMock/build/cmock_test.info > FreeRTOS/Test/CMock/build/cmock_test_summary.txt

echo "=== Tests completed successfully ==="
echo "FINAL_STATUS = SUCCESS"
