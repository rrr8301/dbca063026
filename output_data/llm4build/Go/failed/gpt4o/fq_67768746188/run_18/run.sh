#!/bin/bash

# Activate Go environment
export PATH="/usr/local/go/bin:${PATH}"

# Install Go dependencies
go mod tidy

# Run tests
make test
TEST_EXIT_CODE=$?

if [ $TEST_EXIT_CODE -ne 0 ]; then
    echo "Some tests failed. Please check the logs for more details."
    exit $TEST_EXIT_CODE
fi