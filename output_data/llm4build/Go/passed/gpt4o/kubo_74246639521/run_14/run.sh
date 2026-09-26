#!/bin/bash

# Activate Go environment
export PATH="/usr/local/go/bin:${PATH}"

# Clear any problematic GOFLAGS
unset GOFLAGS

# Ensure the Go version in go.mod is correct
sed -i 's/^go .*/go 1.17/' go.mod

# Ensure the Go version in test/dependencies/go.mod is correct
sed -i 's/^go .*/go 1.17/' test/dependencies/go.mod

# Install project dependencies
go mod tidy

# Run unit tests
make test_unit &&
  [[ ! $(jq -s -c 'map(select(.Action == "fail")) | .[]' test/unit/gotest.json) ]]