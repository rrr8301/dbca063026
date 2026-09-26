#!/usr/bin/env bash
set -e

echo "Running tests for grpc-go..."
go version

echo "Running main test suite..."
go test -cpu 1,4 -timeout 7m ./...

cd /app
for MOD_FILE in $(find . -name 'go.mod' | grep -Ev '^\./go\.mod'); do
  pushd "$(dirname ${MOD_FILE})"
  echo "Running tests in $(pwd)..."
  go test -cpu 1,4 -timeout 2m ./...
  popd
done

echo "FINAL_STATUS = SUCCESS"
