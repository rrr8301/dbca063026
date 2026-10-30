#!/bin/bash

# Clone the repository
git clone <repository-url> /app
cd /app

# Run tests
go version
go test -cpu 1,4 -timeout 7m ./...
for MOD_FILE in $(find . -name 'go.mod' | grep -Ev '^\./go\.mod'); do
  pushd "$(dirname ${MOD_FILE})"
  go test -cpu 1,4 -timeout 2m ./...
  popd
done