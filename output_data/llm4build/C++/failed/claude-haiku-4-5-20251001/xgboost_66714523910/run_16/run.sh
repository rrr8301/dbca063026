#!/bin/bash

set -e

# Activate Python environment (already in PATH)
export PATH=/usr/local/bin:/usr/bin:$PATH

cd /workspace

echo "Current working directory: $(pwd)"
echo "Python version:"
python --version
echo "Listing workspace contents:"
ls -la /workspace/

# Check if wheels exist in wheelhouse
echo "Checking for wheels in /workspace/wheelhouse/"
if [ ! -d /workspace/wheelhouse ]; then
    echo "Creating /workspace/wheelhouse directory"
    mkdir -p /workspace/wheelhouse
fi

wheel_count=$(find /workspace/wheelhouse -name "*.whl" -type f 2>/dev/null | wc -l)
if [ "$wheel_count" -eq 0 ]; then
    echo "Warning: No pre-built wheels found in /workspace/wheelhouse/"
    echo "Contents of wheelhouse:"
    ls -la /workspace/wheelhouse/
    echo "Proceeding without pre-built wheel installation..."
else
    echo "Found $wheel_count wheel(s) in wheelhouse"
    find /workspace/wheelhouse -name "*.whl" -type f
    
    # Install the wheel(s)
    echo "Installing XGBoost wheel(s)..."
    for wheel in /workspace/wheelhouse/*.whl; do
        if [ -f "$wheel" ]; then
            echo "Installing: $wheel"
            pip install --force-reinstall --no-cache-dir "$wheel" || {
                echo "Error: Failed to install wheel: $wheel"
                exit 1
            }
        fi
    done
    
    # Verify installation
    echo "Verifying XGBoost installation..."
    python -c "import xgboost; print(f'XGBoost version: {xgboost.__version__}')" || {
        echo "Error: Failed to import xgboost after installation"
        exit 1
    }
fi

# Run Python tests (CPU suite)
echo "Running Python tests (CPU suite)..."
cd /workspace

# Primary method: Use the official test script if it exists
if [ -f ops/pipeline/test-python-wheel.sh ]; then
    echo "Running test suite via ops/pipeline/test-python-wheel.sh..."
    bash ops/pipeline/test-python-wheel.sh --suite cpu
    exit_code=$?
    if [ $exit_code -ne 0 ]; then
        echo "Test suite failed with exit code: $exit_code"
        exit $exit_code
    fi
    echo "Test execution completed successfully."
    exit 0
fi

# Fallback: Run pytest on available test directories
echo "Running pytest on xgboost tests..."

test_found=0

# Check for tests directory in common locations for XGBoost
for test_dir in tests python-package/xgboost/tests xgboost/tests python-package/tests; do
    if [ -d "$test_dir" ]; then
        echo "Found tests in $test_dir"
        echo "Running: python -m pytest $test_dir -v --tb=short"
        python -m pytest "$test_dir" -v --tb=short -x || {
            exit_code=$?
            echo "Tests in $test_dir failed with exit code: $exit_code"
            exit $exit_code
        }
        test_found=1
        break
    fi
done

if [ $test_found -eq 0 ]; then
    echo "Searching for test files in repository..."
    test_files=$(find /workspace -path /workspace/.git -prune -o -name "test_*.py" -type f -print 2>/dev/null | grep -v __pycache__ | grep -v ".egg-info" | head -100)
    
    if [ -n "$test_files" ]; then
        echo "Found test files:"
        echo "$test_files" | head -20
        echo ""
        echo "Running discovered tests..."
        python -m pytest $test_files -v --tb=short -x || {
            exit_code=$?
            echo "Some tests failed with exit code: $exit_code"
            exit $exit_code
        }
        test_found=1
    else
        echo "Warning: No test files found in repository"
        echo "Listing repository structure:"
        find /workspace -type d -name "*test*" 2>/dev/null | grep -v ".git" | head -20
    fi
fi

if [ $test_found -eq 0 ]; then
    echo "Error: Could not locate or run any tests"
    echo "Repository structure:"
    ls -la /workspace/
    exit 1
fi

echo "Test execution completed successfully."