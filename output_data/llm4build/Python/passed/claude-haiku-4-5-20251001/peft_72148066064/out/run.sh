#!/bin/bash

set -e

# Set environment variables for CI
export HF_TOKEN="${HF_TOKEN:-}"
export TRANSFORMERS_IS_CI=1
export CI=1
export HF_HOME=/workspace/.cache/huggingface

# Create cache directory if it doesn't exist
mkdir -p "$HF_HOME/hub"

echo "=== Installing project dependencies ==="
python -m pip install --upgrade pip
pip install setuptools

# Install the project with test dependencies
pip install -e .[test]

echo "=== Running tests ==="
# Run tests via make, capture exit code but continue
make test
TEST_EXIT_CODE=$?

echo "=== Cleaning up temporary pytest directories ==="
rm -rf "/tmp/pytest-of-$(id -u -n)" || true

echo "=== Test execution completed ==="
if [ $TEST_EXIT_CODE -ne 0 ]; then
    echo "Tests failed with exit code: $TEST_EXIT_CODE"
    exit $TEST_EXIT_CODE
else
    echo "All tests passed!"
    exit 0
fi