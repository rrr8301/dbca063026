#!/usr/bin/env bash

cd /app

echo "Running npm run test-node:integration..."
npm run test-node:integration
TEST_EXIT=$?

if [ $TEST_EXIT -eq 0 ]; then
  echo "FINAL_STATUS = SUCCESS"
  exit 0
else
  echo "FINAL_STATUS = FAIL"
  exit 1
fi
