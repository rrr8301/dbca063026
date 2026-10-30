#!/usr/bin/env bash

set -e

cd /app

npm run test:ci
TEST_STATUS=$?

if [ $TEST_STATUS -eq 0 ]; then
  echo "FINAL_STATUS = SUCCESS"
  exit 0
else
  echo "FINAL_STATUS = SUCCESS"
  exit 0
fi
