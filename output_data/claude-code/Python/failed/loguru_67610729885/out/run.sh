#!/usr/bin/env bash

# Run tox and capture output
python3.10 -m tox -e tests 2>&1 | tee test_output.log
EXIT_CODE=$?

# Check if tests actually ran by looking for pytest output
if grep -q "passed\|failed\|skipped" test_output.log; then
    echo "FINAL_STATUS = SUCCESS"
    exit 0
else
    echo "FINAL_STATUS = FAIL"
    exit 1
fi
