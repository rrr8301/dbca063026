#!/bin/bash

# Activate Go environment
export PATH="/usr/local/go/bin:${PATH}"
export PATH="/home/testuser/go/bin:${PATH}"

# Run tests
gotestsum --junitfile unit-tests.xml --format pkgname -- -v -cover -coverpkg=./... -coverprofile=coverage.txt -covermode=atomic -timeout 20m ./...