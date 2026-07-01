#!/bin/bash

# Activate Python environment (if any virtual environment is used)
# source venv/bin/activate

# Install project dependencies
if [ -f ./.github/workflows/install-ubuntu-dependencies.sh ]; then
    ./.github/workflows/install-ubuntu-dependencies.sh --full
else
    echo "Dependency installation script not found!"
    exit 1
fi

# Run the test script
if [ -f test/ci-build.sh ]; then
    test/ci-build.sh
else
    echo "Test script not found!"
    exit 1
fi

# Ensure all tests are executed
set +e