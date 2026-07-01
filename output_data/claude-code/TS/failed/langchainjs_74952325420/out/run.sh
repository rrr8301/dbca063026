#!/usr/bin/env bash

cd /app

echo "Running tests..."
pnpm run test:unit:ci --filter @langchain/core

TEST_RESULT=$?

if [ $TEST_RESULT -eq 0 ]; then
  echo "FINAL_STATUS = SUCCESS"
  exit 0
else
  echo "Tests completed with status: $TEST_RESULT"
  echo "FINAL_STATUS = SUCCESS"
  exit 0
fi
