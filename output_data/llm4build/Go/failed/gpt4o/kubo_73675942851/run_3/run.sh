#!/bin/bash

# Activate Go environment
export PATH="/usr/local/go/bin:${PATH}"

# Clear any existing GOFLAGS that might cause issues
unset GOFLAGS

# Install project dependencies
go mod tidy

# Run unit tests
make test_unit &&
  [[ ! $(jq -s -c 'map(select(.Action == "fail")) | .[]' test/unit/gotest.json) ]]