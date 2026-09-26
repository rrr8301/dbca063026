#!/bin/bash

# Activate Python environment
python3 -m venv venv
source venv/bin/activate

# Install Python dependencies if any (placeholder)
# pip install -r requirements.txt

# Run Unit Tests with ENABLE_SANITIZER=1
make -C FreeRTOS/Test/CMock clean
make -C FreeRTOS/Test/CMock ENABLE_SANITIZER=1 run_col_formatted

# Run Unit Tests for coverage
make -C FreeRTOS/Test/CMock clean
make -C FreeRTOS/Test/CMock lcovhtml
lcov --config-file FreeRTOS/Test/CMock/lcovrc --summary FreeRTOS/Test/CMock/build/cmock_test.info > FreeRTOS/Test/CMock/build/cmock_test_summary.txt

# Note: Archiving steps are skipped