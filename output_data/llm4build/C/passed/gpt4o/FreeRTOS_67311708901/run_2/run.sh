#!/bin/bash

# Activate Python 3.8
update-alternatives --install /usr/bin/python python /usr/bin/python3.8 1

# Install Python dependencies if any (placeholder)
# pip install -r requirements.txt

# Ensure submodules are updated
git submodule update --init --recursive

# Run Unit Tests with ENABLE_SANITIZER=1
make -C FreeRTOS/Test/CMock clean
make -C FreeRTOS/Test/CMock ENABLE_SANITIZER=1 run_col_formatted

# Run Unit Tests for coverage
make -C FreeRTOS/Test/CMock clean
make -C FreeRTOS/Test/CMock lcovhtml
lcov --config-file FreeRTOS/Test/CMock/lcovrc --summary FreeRTOS/Test/CMock/build/cmock_test.info > FreeRTOS/Test/CMock/build/cmock_test_summary.txt