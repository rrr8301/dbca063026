#!/bin/bash

set -e

# Clone the repository (simulating actions/checkout)
if [ ! -d "zstd" ]; then
    git clone https://github.com/facebook/zstd.git
fi

cd zstd

# Set environment variables from the job
export DEVNULLRIGHTS=1
export READFROMBLOCKDEVICE=1

# Run the test suite
echo "Running: make test"
make test || TEST_FAILED=1

# Build zstd with parallel jobs
echo "Running: make -j zstd"
make -j zstd || BUILD_FAILED=1

# Run process substitution tests
echo "Running: ./tests/test_process_substitution.bash ./zstd"
./tests/test_process_substitution.bash ./zstd || PROC_TEST_FAILED=1

# Report results
echo ""
echo "========== Test Summary =========="
if [ -z "$TEST_FAILED" ]; then
    echo "✓ make test: PASSED"
else
    echo "✗ make test: FAILED"
fi

if [ -z "$BUILD_FAILED" ]; then
    echo "✓ make -j zstd: PASSED"
else
    echo "✗ make -j zstd: FAILED"
fi

if [ -z "$PROC_TEST_FAILED" ]; then
    echo "✓ test_process_substitution.bash: PASSED"
else
    echo "✗ test_process_substitution.bash: FAILED"
fi

# Exit with failure if any test failed
if [ -n "$TEST_FAILED" ] || [ -n "$BUILD_FAILED" ] || [ -n "$PROC_TEST_FAILED" ]; then
    exit 1
fi

exit 0