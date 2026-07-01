#!/usr/bin/env bash

set -e

cd /app

# Run build-deps (as per the workflow)
make build-deps

# Run the tests
if pnpm --filter seven test; then
    echo "FINAL_STATUS = SUCCESS"
else
    echo "FINAL_STATUS = FAIL"
    exit 1
fi
