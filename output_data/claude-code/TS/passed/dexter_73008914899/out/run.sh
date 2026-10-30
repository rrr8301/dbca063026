#!/usr/bin/env bash

set -e

echo "Running bun test..."
bun test

if [ $? -eq 0 ]; then
    echo "FINAL_STATUS = SUCCESS"
else
    echo "FINAL_STATUS = FAIL"
    exit 1
fi
