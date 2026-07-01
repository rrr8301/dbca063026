#!/bin/bash

# Activate Go environment
export PATH="/usr/local/go/bin:${PATH}"

# Install project dependencies
# Assuming the correct directory is the root of the workspace
# If 'fiber' is the correct directory, ensure it exists or adjust the path
if [ -d "fiber" ]; then
  cd fiber
fi

# Ensure go.mod has a valid Go version
sed -i 's/^go .*/go 1.20/' go.mod

go mod download

# Run tests
gotestsum --format testname -- ./... -race -count=1 -coverprofile=coverage.txt -covermode=atomic -shuffle=on