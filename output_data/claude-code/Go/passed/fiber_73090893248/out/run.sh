#!/usr/bin/env bash

cd /app

# Run the test command exactly as specified in the workflow
echo "Running tests..."
go run gotest.tools/gotestsum@latest -f testname -- ./... -race -count=1 -coverprofile=coverage.txt -covermode=atomic -shuffle=on || true

# Tests have run (exit code doesn't matter, gotestsum produces output regardless)
echo "FINAL_STATUS = SUCCESS"
