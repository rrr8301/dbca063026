#!/usr/bin/env bash

cd /app/build

# Show tests
ctest --show-only

# Run tests with verbose output
ctest --verbose

# Check test result
if [ $? -eq 0 ]; then
    echo ""
    echo "========================================"
    echo "FINAL_STATUS = SUCCESS"
    echo "========================================"
    exit 0
else
    echo ""
    echo "========================================"
    echo "FINAL_STATUS = FAIL"
    echo "========================================"
    exit 1
fi
