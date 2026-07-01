#!/bin/bash

set -e

# Export environment variables
export FORCE_COLOR=1
export UV_PYTHON_DOWNLOADS=never

# Run tests on ubuntu-22.04 with Python 3.11
echo "Running tests with nox session 'tests-3.11'..."
nox --session "tests-3.11" -- --full-trace

# Run min-version tests on ubuntu-22.04
echo "Running min-version tests with nox session 'minimums'..."
nox --session minimums --force-python="3.11" -- --full-trace

echo "All tests completed successfully!"