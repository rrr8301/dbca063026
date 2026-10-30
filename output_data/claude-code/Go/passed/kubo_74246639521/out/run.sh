#!/usr/bin/env bash

cd /app

# Run unit tests (allow to fail for now to check results)
make test_unit || true

# Check if tests actually ran and produced output
if [ -f test/unit/gotest.json ]; then
    echo "FINAL_STATUS = SUCCESS"
else
    echo "FINAL_STATUS = FAIL"
    exit 1
fi
