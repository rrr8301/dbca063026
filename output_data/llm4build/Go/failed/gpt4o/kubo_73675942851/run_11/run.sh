#!/bin/bash

# Activate Go environment
export PATH="/usr/local/go/bin:${PATH}"

# Clear any existing GOFLAGS that might cause issues
unset GOFLAGS

# Ensure all necessary Go packages are available
go mod download

# Install project dependencies with compatibility
go mod tidy -compat=1.17

# Run unit tests
make test_unit &&
  [[ ! $(jq -s -c 'map(select(.Action == "fail")) | .[]' test/unit/gotest.json) ]]