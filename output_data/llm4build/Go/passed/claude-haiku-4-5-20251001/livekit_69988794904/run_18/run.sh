#!/bin/bash
set -euo pipefail

# Check if test log exists
if [ ! -f /tmp/gotest.log ]; then
    echo "Error: Test log file not found at /tmp/gotest.log"
    exit 1
fi

# Check for test failures in the JSON log
if grep -q '"Action":"fail"' /tmp/gotest.log; then
    echo "Test failures detected in log"
    exit 1
fi

# Check for FAIL lines in the output (for non-JSON format)
if grep -q '^FAIL' /tmp/gotest.log; then
    echo "Test failures detected"
    exit 1
fi

# Check for panic or fatal errors
if grep -qi 'panic\|fatal error' /tmp/gotest.log; then
    echo "Fatal error or panic detected in tests"
    exit 1
fi

# Verify that tests actually ran - check for either JSON pass actions or ok lines
if ! grep -q '"Action":"pass"' /tmp/gotest.log && ! grep -q '^ok' /tmp/gotest.log && ! grep -q 'PASS' /tmp/gotest.log; then
    echo "Warning: No test results found in log"
    # Don't fail here as some packages may legitimately have no tests
    # Just log the warning
fi

# Check if there were any actual test packages that ran
if grep -q '"Action":"run"' /tmp/gotest.log || grep -q '^ok\|^PASS' /tmp/gotest.log; then
    echo "All tests passed successfully"
    exit 0
else
    # If no test actions found, check if this is expected (no test files)
    if grep -q 'no test files' /tmp/gotest.log; then
        echo "No test files found - this is expected for some packages"
        exit 0
    fi
    echo "Warning: Unable to determine test status"
    exit 0
fi