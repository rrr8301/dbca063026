#!/usr/bin/env bash
set -e

export CI=true

echo "Running: npm run build-and-test"
npm run build-and-test

if [ $? -eq 0 ]; then
  echo "FINAL_STATUS = SUCCESS"
else
  echo "FINAL_STATUS = FAIL"
  exit 1
fi
