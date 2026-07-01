#!/bin/bash

set -e

# Activate Python environment (already in PATH)
export PATH=/usr/bin:$PATH

cd /workspace

echo "Current working directory: $(pwd)"
echo "Listing workspace contents:"
ls -la /workspace/

# Check if wheels exist in wheelhouse
echo "Checking for wheels in /workspace/wheelhouse/"
if [ ! -d /workspace/wheelhouse ]; then
    echo "Error: /workspace/wheelhouse directory does not exist"
    exit 1
fi

wheel_count=$(find /workspace/wheelhouse -name "*.whl" -type f | wc -l)
if [ "$wheel_count" -eq 0 ]; then
    echo "Error: No pre-built wheels found in /workspace/wheelhouse/"
    echo "Contents of wheelhouse:"
    ls -la /workspace/wheelhouse/
    echo "Expected wheels to be downloaded/provided before running tests."
    exit 1
fi

echo "Found $wheel_count wheel(s) in wheelhouse"
find /workspace/wheelhouse -name "*.whl" -type f

# Install the wheel(s)
echo "Installing XGBoost wheel(s)..."
for wheel in /workspace/wheelhouse/*.whl; do
    if [ -f "$wheel" ]; then
        echo "Installing: $wheel"
        pip install --force-reinstall --no-cache-dir "$wheel"
    fi
done

# Verify installation
echo "Verifying XGBoost installation..."
python -c "import xgboost; print(f'XGBoost version: {xgboost.__version__}')" || {
    echo "Error: Failed to import xgboost after installation"
    exit 1
}

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
    
    # Check for tests directory in common locations
    for test_dir in tests python-package/xgboost/tests xgboost/tests python-package/tests; do
        if [ -d "$test_dir" ]; then
            echo "Found tests in $test_dir"
            echo "Running: python -m pytest $test_dir -v --tb=short -x"
            python -m pytest "$test_dir" -v --tb=short -x
            test_found=1
            break
        fi
    done
    
    if [ $test_found -eq 0 ]; then
        echo "Warning: No test directory found in standard locations"
        echo "Searched locations:"
        echo "  - tests/"
        echo "  - python-package/xgboost/tests/"
        echo "  - xgboost/tests/"
        echo "  - python-package/tests/"
        
        # Try to find any test files
        echo ""
        echo "Searching for test files in repository..."
        test_files=$(find /workspace -name "test_*.py" -o -name "*_test.py" | head -20)
        if [ -n "$test_files" ]; then
            echo "Found test files:"
            echo "$test_files"
            echo ""
            echo "Running discovered tests..."
            python -m pytest $test_files -v --tb=short -x
            test_found=1
        else
            echo "Error: No test files found in repository"
            exit 1
        fi
    fi
fi

echo "Test execution completed successfully."