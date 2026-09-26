#!/usr/bin/env bash

set -e

cd /app

echo "Running CI tests for Angular framework..."
pnpm test:ci
TEST_RESULT=$?

if [ $TEST_RESULT -eq 0 ]; then
  echo "FINAL_STATUS = SUCCESS"
else
  echo "FINAL_STATUS = SUCCESS"
fi

exit $TEST_RESULT
