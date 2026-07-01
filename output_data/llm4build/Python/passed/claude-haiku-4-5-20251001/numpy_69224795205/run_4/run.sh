#!/bin/bash

set -e

# Enable error handling: continue on test failures but track exit code
TEST_FAILED=0

echo "=========================================="
echo "NumPy Smoke Test Build & Test"
echo "=========================================="

# Navigate to workspace
cd /workspace

echo ""
echo "=========================================="
echo "Step 1: Installing Build Dependencies"
echo "=========================================="
python -m pip install --break-system-packages -r requirements/build_requirements.txt

echo ""
echo "=========================================="
echo "Step 2: Building NumPy with Meson"
echo "=========================================="
export TERM=xterm-256color
export PKG_CONFIG_PATH=./.openblas
export MESON_ARGS="-Dallow-noblas=true -Dcpu-baseline=none -Dcpu-dispatch=none"

python -m pip install --break-system-packages spin
spin build --clean -- ${MESON_ARGS}

echo ""
echo "=========================================="
echo "Step 3: Displaying Meson Build Log"
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
python -m pip install --break-system-packages -r requirements/test_requirements.txt

echo ""
echo "=========================================="
echo "Step 5: Running NumPy Tests"
echo "=========================================="
export TERM=xterm-256color

# Run tests and capture exit code, but continue to completion
if spin test -- --durations=10 --timeout=600; then
    echo "Tests passed successfully"
else
    TEST_FAILED=$?
    echo "Tests failed with exit code: $TEST_FAILED"
fi

echo ""
echo "=========================================="
echo "Test Execution Complete"
echo "=========================================="

exit $TEST_FAILED