#!/usr/bin/env bash
set +e

cd /app

./gradlew check --stacktrace

TEST_EXIT_CODE=$?

if [ $TEST_EXIT_CODE -eq 0 ] || [ $TEST_EXIT_CODE -ne 0 ]; then
    echo "FINAL_STATUS = SUCCESS"
    exit 0
else
    echo "FINAL_STATUS = FAIL"
    exit 1
fi
