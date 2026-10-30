#!/bin/bash

set -e

# Set pytest options for parallel execution
export PYTEST_ADDOPTS="-n auto"

# Upgrade pip and setuptools with --break-system-packages flag
python -m pip install --upgrade --break-system-packages setuptools pip

# Install project with develop, gmpy2, gmp, and ci extras
python -m pip install --upgrade ".[develop,gmpy2,gmp,ci]"

# Run pytest
# Use set +e to capture exit code but continue to ensure all tests run
set +e
pytest
TEST_EXIT_CODE=$?
set -e

# Exit with the test result code
exit $TEST_EXIT_CODE