#!/bin/bash
set -euo pipefail

# Check if test log exists
if [ ! -f /tmp/gotest.log ]; then
    echo "Error: Test log file not found at /tmp/gotest.log"
    exit 1
fi

# Check for test failures in the log
if grep -q '"Action":"fail"' /tmp/gotest.log; then
    echo "Test failures detected in log"
    exit 1
fi

# Check for FAIL lines in the output
if grep -q '^FAIL' /tmp/gotest.log; then
    echo "Test failures detected"
    exit 1
fi

# Verify that tests actually ran
if ! grep -q '"Action":"pass"' /tmp/gotest.log && ! grep -q '^ok' /tmp/gotest.log; then
    echo "Warning: No test results found in log"
    exit 1
fi

echo "All tests passed successfully"
exit 0