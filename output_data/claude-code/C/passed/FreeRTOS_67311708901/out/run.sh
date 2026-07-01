#!/usr/bin/env bash

set -e

cd /app

echo "=== Run Unit Tests with ENABLE_SANITIZER=1 ==="
make -C FreeRTOS/Test/CMock clean
make -C FreeRTOS/Test/CMock ENABLE_SANITIZER=1 run_col_formatted

echo "=== Run Unit Tests for coverage ==="
make -C FreeRTOS/Test/CMock clean
make -C FreeRTOS/Test/CMock lcovhtml
lcov --config-file FreeRTOS/Test/CMock/lcovrc --summary FreeRTOS/Test/CMock/build/cmock_test.info > FreeRTOS/Test/CMock/build/cmock_test_summary.txt

echo "FINAL_STATUS = SUCCESS"
