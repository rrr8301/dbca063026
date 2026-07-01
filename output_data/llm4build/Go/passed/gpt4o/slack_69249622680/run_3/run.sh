#!/bin/bash

# Activate Go environment
export PATH="/usr/local/go/bin:${PATH}"

# Enable CGO
export CGO_ENABLED=1

# Install project dependencies
go mod download

# Run tests
go test -v -race ./...

# Ensure all tests are executed, even if some fail
exit_code=0
for pkg in $(go list ./...); do
    go test -v -race "$pkg" || exit_code=$?
done

exit $exit_code