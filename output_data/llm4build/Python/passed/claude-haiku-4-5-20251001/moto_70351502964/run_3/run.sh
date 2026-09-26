#!/bin/bash
set -e

# Upgrade pip
python -m pip install --upgrade pip

# Install project dependencies
if [ -f requirements-dev.txt ]; then
    pip install -r requirements-dev.txt
fi
pip install pytest-github-actions-annotate-failures

# Run tests with TESTS_SKIP_REQUIRES_DOCKER environment variable
export TESTS_SKIP_REQUIRES_DOCKER=true

# Try to find and run tests
if [ -d "tests" ]; then
    pytest tests -v --tb=short
elif [ -d "test" ]; then
    pytest test -v --tb=short
else
    # Fallback: discover tests in current directory
    pytest . -v --tb=short -p no:warnings
fi