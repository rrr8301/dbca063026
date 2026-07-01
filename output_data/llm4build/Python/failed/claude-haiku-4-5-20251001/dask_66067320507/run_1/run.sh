#!/bin/bash

set -e

# Verify repository exists
if [ ! -d "/workspace/dask" ]; then
    echo "Error: Repository not found at /workspace/dask"
    echo "Please mount or copy the dask repository to /workspace/dask"
    exit 1
fi

cd /workspace/dask

# Verify environment file exists
if [ ! -f "continuous_integration/environment-3.13.yaml" ]; then
    echo "Error: Environment file not found at continuous_integration/environment-3.13.yaml"
    exit 1
fi

# Initialize conda
eval "$(conda shell.bash hook)"

# Create and activate conda environment from file
echo "Setting up Conda environment from continuous_integration/environment-3.13.yaml..."
mamba env create -f continuous_integration/environment-3.13.yaml -n test-environment --yes
conda activate test-environment

# Reconfigure pytest-timeout: thread → signal
echo "Reconfiguring pytest-timeout..."
if [ -f "pyproject.toml" ]; then
    sed -i.bak 's/timeout_method = "thread"/timeout_method = "signal"/' pyproject.toml
else
    echo "Warning: pyproject.toml not found, skipping pytest-timeout reconfiguration"
fi

# Install the project
echo "Installing project dependencies..."
if [ -f "continuous_integration/scripts/install.sh" ]; then
    source continuous_integration/scripts/install.sh
else
    echo "Error: install.sh not found"
    exit 1
fi

# Run import tests
echo "Running import tests..."
IMPORT_TEST_FAILED=0
pytest dask/tests/test_imports.py || IMPORT_TEST_FAILED=1

# Run full test suite with environment variables
echo "Running full test suite..."
export PARALLEL="true"
export COVERAGE="true"
export ARRAYEXPR="false"
export HDF5_USE_FILE_LOCKING="FALSE"

TEST_SUITE_FAILED=0
if [ -f "continuous_integration/scripts/run_tests.sh" ]; then
    source continuous_integration/scripts/run_tests.sh || TEST_SUITE_FAILED=1
else
    echo "Error: run_tests.sh not found"
    exit 1
fi

# Summary
echo ""
echo "========== Test Summary =========="
if [ "$IMPORT_TEST_FAILED" -eq 0 ]; then
    echo "✓ Import tests passed"
else
    echo "✗ Import tests failed"
fi

if [ "$TEST_SUITE_FAILED" -eq 0 ]; then
    echo "✓ Test suite passed"
else
    echo "✗ Test suite failed"
fi

# Exit with failure if any tests failed
if [ "$IMPORT_TEST_FAILED" -ne 0 ] || [ "$TEST_SUITE_FAILED" -ne 0 ]; then
    exit 1
fi

exit 0