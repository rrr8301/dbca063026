#!/bin/bash

set -e

# Activate Python environment (already in PATH)
export PATH=/usr/bin:$PATH

cd /workspace

# Check if wheels exist in wheelhouse, if not look for them in python-package/dist
if [ ! -f /workspace/wheelhouse/*.whl ] 2>/dev/null; then
    if [ -d /workspace/python-package/dist ] && [ -f /workspace/python-package/dist/*.whl ] 2>/dev/null; then
        echo "Copying wheels from python-package/dist to wheelhouse..."
        mkdir -p /workspace/wheelhouse
        cp /workspace/python-package/dist/*.whl /workspace/wheelhouse/
    else
        echo "Warning: No pre-built wheels found. Attempting to build from source..."
        
        # Initialize git if needed for submodules
        if [ ! -d .git ]; then
            git init
            git config user.email "builder@example.com"
            git config user.name "Builder"
            git add .
            git commit -m "Initial commit"
        fi
        
        # Update submodules
        git submodule update --init --recursive 2>/dev/null || true
        
        # Build libxgboost with CMake
        mkdir -p /workspace/build
        cd /workspace/build
        cmake .. && make -j$(nproc)
        cd /workspace
        
        # Build the wheel
        echo "Building XGBoost wheel..."
        if [ -d /workspace/python-package ]; then
            cd /workspace/python-package
            python setup.py bdist_wheel
            mkdir -p /workspace/wheelhouse
            cp dist/*.whl /workspace/wheelhouse/
            cd /workspace
        else
            echo "Error: python-package directory not found"
            exit 1
        fi
    fi
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
    # Fallback: Run pytest on the xgboost tests directory
    echo "Running pytest on xgboost tests..."
    if [ -d xgboost/tests ]; then
        python -m pytest xgboost/tests/ -v --tb=short -x
    elif [ -d tests ]; then
        python -m pytest tests/ -v --tb=short -x
    else
        echo "Warning: No test directory found at xgboost/tests or tests/"
        echo "Attempting to run any available tests..."
        python -m pytest . -v --tb=short -x 2>/dev/null || echo "No pytest tests found"
    fi
fi

echo "Test execution completed."