#!/usr/bin/env bash
set -e

echo "Running tests..."
cd /app
make test

# Print final status
if [ $? -eq 0 ]; then
  echo "FINAL_STATUS = SUCCESS"
else
  echo "FINAL_STATUS = FAIL"
fi
