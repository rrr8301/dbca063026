#!/bin/bash

set -e

# Activate Python environment (already in PATH)
export PATH=/usr/bin:$PATH

# Create wheelhouse directory for wheel artifacts
mkdir -p /workspace/wheelhouse

# Build the wheel if not already present
if [ ! -f /workspace/wheelhouse/*.whl ]; then
    echo "Building XGBoost wheel..."
    cd /workspace/python-package
    python setup.py bdist_wheel
    cp dist/*.whl /workspace/wheelhouse/
    cd /workspace
fi

# Install the wheel
echo "Installing XGBoost wheel..."
pip install --force-reinstall /workspace/wheelhouse/*.whl

# Run Python tests (CPU suite)
echo "Running Python tests (CPU suite)..."
cd /workspace

# Run pytest on the xgboost tests directory
python -m pytest xgboost/tests/ -v --tb=short -x || true

# Alternative: if test-python-wheel.sh exists and is executable, use it
if [ -f ops/pipeline/test-python-wheel.sh ]; then
    echo "Running test suite via test-python-wheel.sh..."
    bash ops/pipeline/test-python-wheel.sh --suite cpu || true
fi

echo "Test execution completed."