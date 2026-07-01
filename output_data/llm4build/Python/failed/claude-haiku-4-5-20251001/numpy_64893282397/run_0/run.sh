#!/bin/bash

set -e

# Enable error handling: continue on test failures but report them
TEST_FAILED=0

echo "=========================================="
echo "NumPy Smoke Test Build and Test"
echo "=========================================="

# Set environment variables
export MESON_ARGS="-Dallow-noblas=true -Dcpu-baseline=none -Dcpu-dispatch=none"
export PKG_CONFIG_PATH=./.openblas
export TERM=xterm-256color

# Navigate to workspace
cd /workspace

echo ""
echo "=========================================="
echo "Step 1: Installing Build Dependencies"
echo "=========================================="
python -m pip install -r requirements/build_requirements.txt

echo ""
echo "=========================================="
echo "Step 2: Building NumPy"
echo "=========================================="
python -m pip install spin
spin build --clean -- ${MESON_ARGS}

echo ""
echo "=========================================="
echo "Step 3: Displaying Meson Log"
echo "=========================================="
if [ -f build/meson-logs/meson-log.txt ]; then
    cat build/meson-logs/meson-log.txt
else
    echo "Warning: Meson log file not found"
fi

echo ""
echo "=========================================="
echo "Step 4: Installing Test Dependencies"
echo "=========================================="
python -m pip install -r requirements/test_requirements.txt

echo ""
echo "=========================================="
echo "Step 5: Running Tests"
echo "=========================================="
if spin test -- --durations=10 --timeout=600; then
    echo "Tests passed successfully"
else
    TEST_FAILED=1
    echo "Tests failed with exit code: $?"
fi

echo ""
echo "=========================================="
echo "Test Summary"
echo "=========================================="
if [ $TEST_FAILED -eq 0 ]; then
    echo "All tests completed successfully"
    exit 0
else
    echo "Some tests failed"
    exit 1
fi