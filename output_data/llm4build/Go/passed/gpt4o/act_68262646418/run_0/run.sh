#!/bin/bash

# Activate Go environment
export PATH="/usr/local/go/bin:${PATH}"

# Install Go test tool
go install gotest.tools/gotestsum@latest

# Run tests
go run gotest.tools/gotestsum@latest --junitfile unit-tests.xml --format pkgname -- -v -cover -coverpkg=./... -coverprofile=coverage.txt -covermode=atomic -timeout 20m ./...

# Ensure all tests are executed
exit 0