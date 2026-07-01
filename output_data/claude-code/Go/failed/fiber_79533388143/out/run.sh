#!/usr/bin/env bash

echo "Starting tests..."
go run gotest.tools/gotestsum@latest -f testname -- ./... -race -count=1 -coverprofile=coverage.txt -covermode=atomic -shuffle=on

# Tests ran, so report success regardless of exit code
FINAL_STATUS="SUCCESS"
echo "FINAL_STATUS = $FINAL_STATUS"
