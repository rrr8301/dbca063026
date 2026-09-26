#!/usr/bin/env bash

set -e

cd /app

# Run the tests using the same command as CI
python3 ./ci/run-tests.py --locked

echo "FINAL_STATUS = SUCCESS"
