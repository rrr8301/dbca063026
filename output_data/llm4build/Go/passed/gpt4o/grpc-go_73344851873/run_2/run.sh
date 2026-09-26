#!/bin/bash

# Navigate to the app directory
cd /app

# Update go.mod files to use the correct Go version
find . -name 'go.mod' -exec sed -i 's/^go [0-9]\+\.[0-9]\+\.[0-9]\+/go 1.20/' {} +

# Install project dependencies
# Assuming dependencies are managed via go.mod and go.sum

# Run tests
go version
go test -cpu 1,4 -timeout 7m ./...
for MOD_FILE in $(find . -name 'go.mod' | grep -Ev '^\./go\.mod'); do
  pushd "$(dirname ${MOD_FILE})"
  go test -cpu 1,4 -timeout 2m ./...
  popd
done