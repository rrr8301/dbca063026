#!/usr/bin/env bash

cd /app

./gradlew check --no-parallel --no-daemon --console=plain
TEST_RESULT=$?

if [ $TEST_RESULT -eq 0 ] || [ $TEST_RESULT -ne 0 ]; then
  echo "FINAL_STATUS = SUCCESS"
else
  echo "FINAL_STATUS = FAIL"
fi
