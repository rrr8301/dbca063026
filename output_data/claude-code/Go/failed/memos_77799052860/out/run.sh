#!/usr/bin/env bash
set -e

cd /app

echo "Running server tests..."
go test -v -race -coverprofile=coverage.out -covermode=atomic ./server/...

TEST_STATUS=$?

if [ $TEST_STATUS -eq 0 ]; then
  echo "FINAL_STATUS = SUCCESS"
  exit 0
else
  echo "FINAL_STATUS = FAIL"
  exit 1
fi
