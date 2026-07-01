#!/bin/bash

set -e

# Clone the repository (assuming it's passed as an environment variable or argument)
# If running locally, the repo should already be mounted/copied
if [ ! -d ".git" ]; then
    echo "Repository not found. Cloning from GitHub..."
    git clone https://github.com/google/mobly.git /workspace
    cd /workspace
fi

# Upgrade pip
python -m pip install --upgrade pip

# Install tox
pip install tox

# Run tox tests
echo "Running tox tests..."
tox || TEST_FAILED=1

# Install pyink for formatting check
pip install pyink==24.3.0

# Check formatting
echo "Checking code formatting with pyink..."
pyink --check . || FORMAT_FAILED=1

# Report results
if [ "$TEST_FAILED" = "1" ] || [ "$FORMAT_FAILED" = "1" ]; then
    echo "Some checks failed!"
    exit 1
fi

echo "All checks passed!"
exit 0