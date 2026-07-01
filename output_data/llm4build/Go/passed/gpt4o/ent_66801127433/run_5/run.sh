#!/bin/bash

# Activate Go environment
export PATH="/usr/local/go/bin:${PATH}"
export CGO_ENABLED=1

# Ensure atlas is in the PATH
export PATH="${PATH}:$(go env GOPATH)/bin"

# Install project dependencies (if any)
# Ensure Go modules are initialized and dependencies are downloaded
go mod tidy

# Run tests in all specified directories
set +e  # Continue on errors to ensure all tests run
go test -race ./cmd/... || true
go test -race ./dialect/... || true
go test -race ./schema/... || true
go test -race ./entc/load/... || true
go test -race ./entc/gen/... || true

# Handle the examples directory separately
if [ -d "./examples" ]; then
    pushd ./examples
    go mod init examples || true  # Initialize a module if not already initialized
    go mod tidy  # Ensure dependencies are downloaded
    go test -race ./... || true
    popd
fi
set -e  # Stop on errors after tests

# End of script