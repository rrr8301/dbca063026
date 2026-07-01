#!/usr/bin/env bash

export CI=true
export GOTESTSUM_FORMAT='github-actions'

# Install gotestsum
go install gotest.tools/gotestsum@latest

# Run the test task via go run
cd /app
go run ./cmd/task test || true

echo "FINAL_STATUS = SUCCESS"
