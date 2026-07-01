#!/bin/bash

set -e

# Print environment info
echo "Python version:"
python --version

echo "Pip version:"
pip --version

echo "Current directory:"
pwd

echo "Environment variables:"
echo "NB_KERNEL=$NB_KERNEL"
echo "MPLBACKEND=$MPLBACKEND"
echo "SEABORN_DATA=$SEABORN_DATA"
echo "PYDEVD_DISABLE_FILE_VALIDATION=$PYDEVD_DISABLE_FILE_VALIDATION"

# Run tests
echo "Running tests..."
make test

echo "Tests completed successfully!"