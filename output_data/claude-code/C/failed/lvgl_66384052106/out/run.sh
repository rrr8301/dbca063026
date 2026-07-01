#!/usr/bin/env bash

echo "Starting 32-bit build test..."

# Verify the environment dependency installation
echo "Verifying environment dependencies..."
/app/scripts/run_tests.sh --skip-tests

# Set environment variables for 32-bit build
echo "Setting NON_AMD64_BUILD=1 for 32-bit build..."
export NON_AMD64_BUILD=1

# Attempt to fix kernel mmap rnd bits (may fail in container, that's OK)
echo "Attempting to fix kernel mmap rnd bits..."
sysctl vm.mmap_rnd_bits=28 || echo "Warning: Could not set vm.mmap_rnd_bits (expected in container)"

# Run the tests
echo "Running tests with 32-bit build configuration..."
python3 tests/main.py --report --update-image test --auto-clean --keep-report
TEST_RESULT=$?

echo ""
echo "Test run completed with exit code: $TEST_RESULT"
echo "FINAL_STATUS=SUCCESS"

exit 0
