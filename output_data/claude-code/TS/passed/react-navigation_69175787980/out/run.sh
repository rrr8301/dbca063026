#!/usr/bin/env bash

set -e

cd /app

echo "Running unit tests..."
if yarn test --maxWorkers=2 --coverage; then
  echo "FINAL_STATUS = SUCCESS"
else
  echo "FINAL_STATUS = FAIL"
  exit 1
fi
