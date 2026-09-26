#!/usr/bin/env bash

set -e

cd /app

# Start redis server in background
redis-server --daemonize yes

# Run the build and tests
ci/build

# Check if tests ran successfully
if [ $? -eq 0 ]; then
    echo "FINAL_STATUS = SUCCESS"
else
    echo "FINAL_STATUS = FAIL"
    exit 1
fi
