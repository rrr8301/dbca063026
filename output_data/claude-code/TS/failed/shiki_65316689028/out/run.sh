#!/usr/bin/env bash

set -e

cd /app

echo "=== Running Tests ==="
FORCE_COLOR=3 pnpm test --coverage 2>&1

if [ $? -eq 0 ]; then
  echo "FINAL_STATUS = SUCCESS"
else
  echo "FINAL_STATUS = FAIL"
fi
