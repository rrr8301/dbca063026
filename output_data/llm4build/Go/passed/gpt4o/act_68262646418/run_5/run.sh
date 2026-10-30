#!/bin/bash

# Activate Go environment
export PATH="/usr/local/go/bin:${PATH}"

# Run tests
gotestsum --junitfile unit-tests.xml --format pkgname -- -v -cover -coverpkg=./... -coverprofile=coverage.txt -covermode=atomic -timeout 20m ./...

# Ensure all tests are executed
exit 0