#!/usr/bin/env bash

set -e

cd /app

echo "Starting test run..."

# Set environment variables as per the job
export LD_LIBRARY_PATH=/usr/local/lib
export CFLAGS="-O2 -Wno-unused-result"

# Run the test suite
echo "Running: make tests"
make tests

# If we got here, tests ran successfully
echo "FINAL_STATUS = SUCCESS"
exit 0
