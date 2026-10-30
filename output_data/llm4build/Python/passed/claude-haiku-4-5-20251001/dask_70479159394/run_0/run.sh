#!/bin/bash

set -e

# Initialize conda in bash shell
source /opt/miniforge3/etc/profile.d/conda.sh

# Create and activate conda environment from environment file
echo "Setting up Conda environment from continuous_integration/environment-3.11.yaml..."
mamba env create -f continuous_integration/environment-3.11.yaml -n test-environment --yes
conda activate test-environment

# Reconfigure pytest-timeout to use signal instead of thread
echo "Reconfiguring pytest-timeout..."
sed -i.bak 's/timeout_method = "thread"/timeout_method = "signal"/' pyproject.toml

# Install the project
echo "Installing project dependencies..."
source continuous_integration/scripts/install.sh

# Run import tests
echo "Running import tests..."
pytest dask/tests/test_imports.py || IMPORT_TEST_FAILED=1

# Run main tests with environment variables
echo "Running main test suite..."
export PARALLEL="true"
export COVERAGE="true"
export ARRAYEXPR="false"
export HDF5_USE_FILE_LOCKING="FALSE"

source continuous_integration/scripts/run_tests.sh || TESTS_FAILED=1

# Report results
echo "=========================================="
echo "Test Summary"
echo "=========================================="
if [ -z "$IMPORT_TEST_FAILED" ]; then
    echo "✓ Import tests passed"
else
    echo "✗ Import tests failed"
fi

if [ -z "$TESTS_FAILED" ]; then
    echo "✓ Main tests passed"
else
    echo "✗ Main tests failed"
fi

# Exit with failure if any tests failed
if [ -n "$IMPORT_TEST_FAILED" ] || [ -n "$TESTS_FAILED" ]; then
    exit 1
fi

exit 0