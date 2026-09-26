#!/bin/bash

set -e

# Activate Python environment (already in PATH)
export PATH=/usr/bin:$PATH

cd /workspace

# Check if wheels exist in wheelhouse
if ! ls /workspace/wheelhouse/*.whl 1> /dev/null 2>&1; then
    echo "Error: No pre-built wheels found in /workspace/wheelhouse/"
    echo "Expected wheels to be downloaded/provided before running tests."
    exit 1
fi

# Install the wheel
echo "Installing XGBoost wheel..."
pip install --force-reinstall /workspace/wheelhouse/*.whl

# Run Python tests (CPU suite)
echo "Running Python tests (CPU suite)..."
cd /workspace

# Check if test-python-wheel.sh exists and use it (preferred method)
if [ -f ops/pipeline/test-python-wheel.sh ]; then
    echo "Running test suite via test-python-wheel.sh..."
    bash ops/pipeline/test-python-wheel.sh --suite cpu
else
    # Fallback: Run pytest on available test directories
    echo "Running pytest on xgboost tests..."
    
    # Try multiple possible test locations
    test_found=0
    
    if [ -d xgboost/tests ]; then
        echo "Found tests in xgboost/tests/"
        python -m pytest xgboost/tests/ -v --tb=short -x
        test_found=1
    elif [ -d tests ]; then
        echo "Found tests in tests/"
        python -m pytest tests/ -v --tb=short -x
        test_found=1
    fi
    
    if [ $test_found -eq 0 ]; then
        echo "Error: No test directory found at xgboost/tests or tests/"
        exit 1
    fi
fi

echo "Test execution completed successfully."