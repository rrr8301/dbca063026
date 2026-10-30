#!/usr/bin/env bash

set -e

cd /app

echo "Running tests with pnpm test..."
pnpm test

if [ $? -eq 0 ]; then
  echo "FINAL_STATUS = SUCCESS"
else
  echo "FINAL_STATUS = FAIL"
  exit 1
fi
