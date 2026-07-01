#!/bin/bash

# Clone the repository
git clone https://github.com/your/repo.git /app
cd /app

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