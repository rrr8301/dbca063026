#!/usr/bin/env bash

set -e

echo "Running tests..."
npm run test

if [ $? -eq 0 ]; then
    echo "FINAL_STATUS = SUCCESS"
    exit 0
else
    echo "FINAL_STATUS = FAIL"
    exit 1
fi
