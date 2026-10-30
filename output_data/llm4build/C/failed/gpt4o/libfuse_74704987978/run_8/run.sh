#!/bin/bash

# Activate any necessary environments (if applicable)

# Install project dependencies
# Ensure the path to the script is correct
if [ -f "./.github/workflows/install-ubuntu-dependencies.sh" ]; then
    ./.github/workflows/install-ubuntu-dependencies.sh --full
else
    echo "Dependency installation script not found!"
    exit 1
fi

# Run tests
# Ensure the path to the script is correct
if [ -f "test/ci-build.sh" ]; then
    test/ci-build.sh
else
    echo "CI build script not found!"
    exit 1
fi