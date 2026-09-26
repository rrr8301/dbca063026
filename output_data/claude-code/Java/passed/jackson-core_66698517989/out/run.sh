#!/usr/bin/env bash
set -e

cd /app

echo "Running Maven build and tests..."
./mvnw -B -ff -ntp verify

if [ $? -eq 0 ]; then
  echo "FINAL_STATUS = SUCCESS"
else
  echo "FINAL_STATUS = FAIL"
  exit 1
fi
