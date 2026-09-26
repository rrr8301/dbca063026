#!/bin/bash

set -e

# Enable error handling: continue on test failures but track exit status
TEST_FAILED=0

echo "=========================================="
echo "LVGL C/C++ Test Suite"
echo "=========================================="

# Change to workspace directory
cd /workspace

echo ""
echo "Step 1: Installing prerequisites..."
if [ -f "scripts/install-prerequisites.sh" ]; then
    bash scripts/install-prerequisites.sh || { echo "Prerequisites installation failed"; TEST_FAILED=1; }
else
    echo "Warning: scripts/install-prerequisites.sh not found"
fi

echo ""
echo "Step 2: Installing pngquant..."
if [ -f "scripts/install_pngquant.sh" ]; then
    bash scripts/install_pngquant.sh || { echo "pngquant installation failed"; TEST_FAILED=1; }
else
    echo "Warning: scripts/install_pngquant.sh not found"
fi

echo ""
echo "Step 3: Verifying environment dependency installation..."
if [ -f "scripts/run_tests.sh" ]; then
    bash scripts/run_tests.sh --skip-tests || { echo "Environment verification failed"; TEST_FAILED=1; }
else
    echo "Warning: scripts/run_tests.sh not found"
fi

echo ""
echo "Step 4: Attempting to fix kernel mmap rnd bits..."
# Note: This requires elevated privileges; may fail in container without CAP_SYS_ADMIN
if command -v sysctl &> /dev/null; then
    sudo sysctl vm.mmap_rnd_bits=28 || echo "Warning: Could not set mmap_rnd_bits (may require elevated privileges)"
else
    echo "Warning: sysctl not available"
fi

echo ""
echo "Step 5: Running test suite..."
if [ -f "tests/main.py" ]; then
    python3 tests/main.py --report --update-image test --auto-clean --keep-report || { echo "Test suite execution failed"; TEST_FAILED=1; }
else
    echo "Warning: tests/main.py not found"
fi

echo ""
echo "Step 6: Code coverage analysis (skipped for local build)..."
echo "Note: Code coverage analysis is conditional on pull request events."
echo "For local builds, this step is skipped."

echo ""
echo "Step 7: Checking for new reference images..."
if [ -d "tests/ref_imgs" ]; then
    NEW_REF_IMGS=$(git status --porcelain -- tests/ref_imgs* 2>/dev/null | grep '^??' | awk '{print $2}' || true)
    
    if [ -n "$NEW_REF_IMGS" ]; then
        echo "New reference images were generated during the build:"
        for file in $NEW_REF_IMGS; do
            echo "  - $file"
        done
        echo "Warning: New reference images should be reviewed and committed."
        TEST_FAILED=1
    else
        echo "No new reference images found."
    fi
else
    echo "Note: tests/ref_imgs directory not found"
fi

echo ""
echo "=========================================="
if [ $TEST_FAILED -eq 0 ]; then
    echo "All tests completed successfully!"
    echo "=========================================="
    exit 0
else
    echo "Some tests or checks failed. Review the output above."
    echo "=========================================="
    exit 1
fi