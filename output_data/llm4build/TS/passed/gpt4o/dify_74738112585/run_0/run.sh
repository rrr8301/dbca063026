#!/bin/bash

# Activate Python virtual environment
source venv/bin/activate

# Install project dependencies
pip install -r dify/api/providers/trace/trace-aliyun/pyproject.toml

# Run tests
echo "Running dify config tests"
# Placeholder for actual test command
# e.g., pytest dify/api/tests

echo "Running Unit Tests"
# Placeholder for actual test command
# e.g., pytest dify/api/unit_tests

# Ensure all tests are executed
set +e
# Example test command
# pytest dify/api/tests --continue-on-collection-errors
set -e

# Complete job
echo "Completing job"