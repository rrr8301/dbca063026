#!/bin/bash

set -e

# Clone the repository with submodules
echo "Cloning repository with submodules..."
git clone --recursive https://github.com/OpenCPN/OpenCPN.git /workspace/repo || true
cd /workspace/repo

# Run pre-build script if it exists
echo "Running pre-build script..."
if [ -f ./ci/github-pre-build.sh ]; then
    # Make the script executable and run it
    chmod +x ./ci/github-pre-build.sh
    bash ./ci/github-pre-build.sh
else
    echo "Warning: Pre-build script not found at ./ci/github-pre-build.sh"
fi

# Configure CMake
echo "Configuring CMake..."
cmake -B build -DCMAKE_BUILD_TYPE=Release

# Build the project
echo "Building project..."
cmake --build build --config Release

# Run tests
echo "Running tests..."
cd build
export CTEST_OUTPUT_ON_FAILURE=1

# Run tests and continue even if they fail
if make run-tests; then
    echo "Tests passed"
else
    echo "Tests failed, but continuing..."
fi

echo "Build and test process completed"