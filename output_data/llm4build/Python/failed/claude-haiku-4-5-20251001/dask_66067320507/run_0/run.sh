#!/bin/bash

set -e

# Clone repository (assuming it's passed as an argument or environment variable)
# For local testing, assume repo is already mounted or copied
if [ ! -d "/workspace/dask" ]; then
    echo "Repository not found. Assuming it will be mounted at /workspace/dask"
    cd /workspace
else
    cd /workspace/dask
fi

# Initialize conda
eval "$(conda shell.bash hook)"

# Create and activate conda environment from file
echo "Setting up Conda environment from continuous_integration/environment-3.13.yaml..."
mamba env create -f continuous_integration/environment-3.13.yaml -n test-environment --yes
conda activate test-environment

# Reconfigure pytest-timeout: thread → signal
echo "Reconfiguring pytest-timeout..."
sed -i.bak 's/timeout_method = "thread"/timeout_method = "signal"/' pyproject.toml

# Install the project
echo "Installing project dependencies..."
source continuous_integration/scripts/install.sh

# Run import tests
echo "Running import tests..."
pytest dask/tests/test_imports.py || IMPORT_TEST_FAILED=1

# Run full test suite with environment variables
echo "Running full test suite..."
export PARALLEL="true"
export COVERAGE="true"
export ARRAYEXPR="false"
export HDF5_USE_FILE_LOCKING="FALSE"

source continuous_integration/scripts/run_tests.sh || TEST_SUITE_FAILED=1

# Summary
echo ""
echo "========== Test Summary =========="
if [ -z "$IMPORT_TEST_FAILED" ]; then
    echo "✓ Import tests passed"
else
    echo "✗ Import tests failed"
fi

if [ -z "$TEST_SUITE_FAILED" ]; then
    echo "✓ Test suite passed"
else
    echo "✗ Test suite failed"
fi

# Exit with failure if any tests failed
if [ -n "$IMPORT_TEST_FAILED" ] || [ -n "$TEST_SUITE_FAILED" ]; then
    exit 1
fi

exit 0