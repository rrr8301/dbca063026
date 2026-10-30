#!/bin/bash

set -e

# Clone the repository (assuming it's passed as an environment variable or argument)
# For local testing, we assume the repo is already mounted or copied
if [ ! -d "/workspace/mobly" ]; then
    if [ -z "$REPO_URL" ]; then
        echo "Error: Repository not found and REPO_URL not set"
        exit 1
    fi
    git clone "$REPO_URL" /workspace/mobly
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