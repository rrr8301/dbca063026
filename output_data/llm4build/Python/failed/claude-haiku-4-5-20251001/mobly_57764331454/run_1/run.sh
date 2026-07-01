#!/bin/bash

set -e

# Check if the repository exists
if [ ! -d "/workspace/mobly" ]; then
    echo "Error: Repository not found at /workspace/mobly"
    exit 1
fi

cd /workspace/mobly

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
    echo "Some checks failed"
    exit 1
fi

echo "All checks passed!"
exit 0