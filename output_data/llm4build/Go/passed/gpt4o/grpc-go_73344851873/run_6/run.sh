#!/bin/bash

# Navigate to the app directory
cd /app

# Initialize Go module if go.mod does not exist
if [ ! -f go.mod ]; then
  go mod init mymodule
fi

# Update go.mod files to use the correct Go version
find . -name 'go.mod' -exec sed -i 's/^go [0-9]\+\.[0-9]\+\.[0-9]\+/go 1.20/' {} +

# Install project dependencies
go mod tidy

# Run tests
go version

# Check if there are any Go files to test
if find . -name '*.go' | grep -q .; then
  go test -cpu 1,4 -timeout 7m ./...
  for MOD_FILE in $(find . -name 'go.mod' | grep -Ev '^\./go\.mod'); do
    pushd "$(dirname ${MOD_FILE})"
    go test -cpu 1,4 -timeout 2m ./...
    popd
  done
else
  echo "No Go files found to test."
fi