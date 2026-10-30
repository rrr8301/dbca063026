#!/usr/bin/env bash

set +e

cd /app

echo "Running make test..."
make test
TEST_RESULT=$?

if [ $TEST_RESULT -eq 0 ]; then
    echo "FINAL_STATUS = SUCCESS"
    exit 0
else
    echo "FINAL_STATUS = FAIL"
    exit 1
fi
