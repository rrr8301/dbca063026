#!/usr/bin/env bash
set -e

cd /app

echo "Running JavaScript tests..."
node ./scripts/run-ci-javascript-tests.js --maxWorkers 2

if [ $? -eq 0 ]; then
  echo "FINAL_STATUS = SUCCESS"
else
  echo "FINAL_STATUS = FAIL"
  exit 1
fi
