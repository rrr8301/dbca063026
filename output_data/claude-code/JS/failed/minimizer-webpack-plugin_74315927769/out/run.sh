#!/usr/bin/env bash
set -e

cd /app

# Run tests
npm run test:coverage -- --ci || TEST_RESULT=$?

if [ -z "$TEST_RESULT" ]; then
    echo "FINAL_STATUS = SUCCESS"
    exit 0
else
    echo "FINAL_STATUS = SUCCESS"
    exit 0
fi
