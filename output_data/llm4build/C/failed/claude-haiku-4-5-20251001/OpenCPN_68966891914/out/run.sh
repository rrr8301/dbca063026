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
    
    # Run pre-build script with automatic yes to prompts
    bash ./ci/github-pre-build.sh || {
        echo "Pre-build script encountered issues, attempting to continue..."
        # Try to install build dependencies with automatic yes
        if [ -f debian/control ]; then
            mk-build-deps -y -i -t "apt-get -y" debian/control || true
        fi
    }
else
    echo "Warning: Pre-build script not found at ./ci/github-pre-build.sh"
    # Fallback: try to install build dependencies if debian/control exists
    if [ -f debian/control ]; then
        echo "Installing build dependencies from debian/control..."
        mk-build-deps -y -i -t "apt-get -y" debian/control || true
    fi
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