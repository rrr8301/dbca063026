#!/bin/bash

set -e

# Change to workspace directory
cd /workspace

echo "=========================================="
echo "Environment Information"
echo "=========================================="
echo "Python version:"
python3 --version
echo "Pip version:"
python3 -m pip --version
echo "Current directory: $(pwd)"
echo "Workspace contents:"
ls -la /workspace/
echo ""

echo "=========================================="
echo "Checking for Python wheel"
echo "=========================================="

# Check if wheel files exist in wheelhouse directory
if [ -d "wheelhouse" ] && [ -n "$(ls -1 wheelhouse/*.whl 2>/dev/null)" ]; then
    echo "Found wheel(s) in wheelhouse directory"
    echo "Wheel files:"
    ls -lh wheelhouse/*.whl
    
    echo ""
    echo "=========================================="
    echo "Installing XGBoost Python wheel (CPU)"
    echo "=========================================="
    python3 -m pip install wheelhouse/*.whl -v
else
    echo "Warning: No wheel files found in wheelhouse directory"
    echo "Wheelhouse directory contents:"
    ls -la wheelhouse/ 2>/dev/null || echo "wheelhouse directory does not exist"
    echo ""
    echo "Available files in workspace:"
    find /workspace -name "*.whl" -type f 2>/dev/null || echo "No wheel files found anywhere"
    echo ""
    echo "Note: If running standalone, wheel files should be in /workspace/wheelhouse/"
    echo "If running in GitHub Actions, wheels are downloaded by manage-artifacts.py"
    echo ""
fi

echo "=========================================="
echo "Verifying test infrastructure"
echo "=========================================="

# Verify ops/pipeline directory exists
if [ ! -d "ops/pipeline" ]; then
    echo "Error: ops/pipeline directory not found"
    echo "Available directories in workspace:"
    ls -la /workspace/
    exit 1
fi

# Verify test script exists
if [ ! -f "ops/pipeline/test-python-wheel.sh" ]; then
    echo "Error: ops/pipeline/test-python-wheel.sh not found"
    echo "Available files in ops/pipeline:"
    ls -la ops/pipeline/ 2>/dev/null || echo "ops/pipeline directory does not exist"
    exit 1
fi

# Make sure the test script is executable
chmod +x ops/pipeline/test-python-wheel.sh

echo "Test script found and made executable"
echo ""

echo "=========================================="
echo "Running Python tests (CPU-amd64)"
echo "=========================================="

# Run the test suite with CPU suite
TEST_EXIT_CODE=0
if bash ops/pipeline/test-python-wheel.sh --suite cpu; then
    TEST_EXIT_CODE=0
else
    TEST_EXIT_CODE=$?
fi

if [ $TEST_EXIT_CODE -ne 0 ]; then
    echo "=========================================="
    echo "Error: Test suite failed with exit code $TEST_EXIT_CODE"
    echo "=========================================="
    exit $TEST_EXIT_CODE
fi

echo "=========================================="
echo "Test execution completed successfully"
echo "=========================================="
exit 0