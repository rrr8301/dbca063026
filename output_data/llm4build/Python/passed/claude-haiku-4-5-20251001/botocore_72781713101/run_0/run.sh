#!/bin/bash

set -e

# Set environment variables
export PYO3_USE_ABI3_FORWARD_COMPATIBILITY=""

# Change to workspace directory
cd /workspace

# Install project in development mode
echo "Installing project in development mode..."
python -m pip install -e .

# Run the custom install script if it exists
if [ -f "scripts/ci/install" ]; then
    echo "Running custom install script..."
    python scripts/ci/install
fi

# Run tests with coverage and xdist
echo "Running tests with coverage and xdist..."
if [ -f "scripts/ci/run-tests" ]; then
    python scripts/ci/run-tests --with-cov --with-xdist
else
    # Fallback: run pytest directly if custom script doesn't exist
    echo "Custom test script not found, running pytest directly..."
    python -m pytest tests/ -v --cov=botocore --cov-report=xml --cov-report=html -n auto
fi

echo "Tests completed successfully!"