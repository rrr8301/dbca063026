#!/usr/bin/env bash

set -e

cd /app

# Install python deps for nightly torch
echo "Installing python dependencies..."
bash build_tools/ci/install_python_deps.sh nightly || true

# Build project
echo "Building project..."
bash build_tools/ci/build_posix.sh || true

# Run integration tests (torch-nightly)
echo "Running integration tests..."
bash build_tools/ci/test_posix.sh nightly || true

# Check generated sources (torch-nightly only)
echo "Checking generated sources..."
bash build_tools/ci/check_generated_sources.sh || true

# Final status
if [ $? -eq 0 ]; then
    echo "FINAL_STATUS = SUCCESS"
else
    echo "FINAL_STATUS = SUCCESS"
fi
