#!/bin/bash

set -e

# Check if we're in a git repository or need to clone
if [ ! -f "setup.py" ] && [ ! -f "pyproject.toml" ] && [ ! -d ".git" ]; then
    echo "Repository not found. Cloning from GitHub..."
    cd /
    rm -rf /workspace
    git clone https://github.com/google/mobly.git /workspace
    cd /workspace
else
    echo "Repository found. Proceeding with tests..."
    cd /workspace
fi

# Upgrade pip
python -m pip install --upgrade pip

# Install tox
pip install tox

# Run tox tests
echo "Running tox tests..."
TEST_FAILED=0
tox || TEST_FAILED=1

# Install pyink for formatting check
pip install pyink==24.3.0

# Check formatting
echo "Checking code formatting with pyink..."
FORMAT_FAILED=0
pyink --check . || FORMAT_FAILED=1

# Report results
if [ "$TEST_FAILED" = "1" ] || [ "$FORMAT_FAILED" = "1" ]; then
    echo "Some checks failed!"
    exit 1
fi

echo "All checks passed!"
exit 0