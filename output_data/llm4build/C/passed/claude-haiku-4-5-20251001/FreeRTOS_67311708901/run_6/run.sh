#!/bin/bash

set -e

cd /workspace

# Check if this is a repository checkout (has FreeRTOS/Test/CMock)
# If not, we need to clone the FreeRTOS repository
if [ ! -d "FreeRTOS/Test/CMock" ]; then
    echo "FreeRTOS/Test/CMock not found. Cloning FreeRTOS repository with submodules..."
    
    # Clone the main FreeRTOS repository which contains the test suite
    # Use --recursive to ensure all submodules (CMock, Unity, etc.) are cloned
    git clone --depth 1 --branch main --recursive https://github.com/FreeRTOS/FreeRTOS.git ./temp_freertos
    
    # Move the FreeRTOS directory structure
    mkdir -p FreeRTOS
    mv ./temp_freertos/FreeRTOS/Source ./FreeRTOS/Source
    mv ./temp_freertos/FreeRTOS/Test ./FreeRTOS/Test
    
    # Clean up
    rm -rf ./temp_freertos
fi

# Verify that FreeRTOS/Test/CMock exists
if [ ! -d "FreeRTOS/Test/CMock" ]; then
    echo "Error: FreeRTOS/Test/CMock directory not found!"
    echo "This directory should be part of the repository being tested."
    exit 1
fi

# Verify that FreeRTOS/Source exists
if [ ! -d "FreeRTOS/Source" ]; then
    echo "Error: FreeRTOS/Source directory not found!"
    exit 1
fi

# Verify that CMock submodule dependencies exist
if [ ! -d "FreeRTOS/Test/CMock/CMock/vendor/unity/src" ]; then
    echo "Error: CMock submodule dependencies not found!"
    echo "Initializing submodules..."
    cd FreeRTOS/Test/CMock
    git submodule update --init --recursive
    cd /workspace
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