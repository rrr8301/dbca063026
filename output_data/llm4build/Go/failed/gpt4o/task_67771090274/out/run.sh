#!/bin/bash

# Activate Go environment (if needed, but Go typically doesn't require activation like Python)
# Install project dependencies
go mod download

# Build the project
go build -o ./bin/task -v ./cmd/task

# Run tests
# Ensure all tests are executed, even if some fail
set +e
./bin/task test --output=group --output-group-begin='::group::{{.TASK}}' --output-group-end='::endgroup::'
set -e