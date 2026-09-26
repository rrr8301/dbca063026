#!/bin/bash
set -e

# Navigate to workspace
cd /workspace

# Install Ubuntu dependencies (full set)
if [ -f ./.github/workflows/install-ubuntu-dependencies.sh ]; then
    ./.github/workflows/install-ubuntu-dependencies.sh --full
fi

# Run the build and test script
if [ -f ./test/ci-build.sh ]; then
    ./test/ci-build.sh
else
    echo "Error: test/ci-build.sh not found"
    exit 1
fi