#!/usr/bin/env bash
set -e

cd /app

# Run the unit tests with coverage
yarn cover:unit --ci --cacheDirectory .jest-cache

# Check if tests passed
if [ $? -eq 0 ]; then
    echo "FINAL_STATUS = SUCCESS"
else
    echo "FINAL_STATUS = FAIL"
    exit 1
fi
