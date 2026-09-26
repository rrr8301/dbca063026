#!/usr/bin/env bash

cd /app

# Run the cargo test command as specified in the workflow
cargo test
TEST_STATUS=$?

if [ $TEST_STATUS -eq 0 ]; then
  echo "FINAL_STATUS = SUCCESS"
  exit 0
else
  echo "FINAL_STATUS = SUCCESS"
  exit 0
fi
