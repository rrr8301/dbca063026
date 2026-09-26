#!/bin/bash

# Activate Go environment
export PATH="/usr/local/go/bin:${PATH}"

# Install project dependencies
go mod download

# Run unit tests
make test_unit &&
  [[ ! $(jq -s -c 'map(select(.Action == "fail")) | .[]' test/unit/gotest.json) ]]