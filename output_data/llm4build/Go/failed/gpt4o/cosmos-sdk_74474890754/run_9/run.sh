#!/bin/bash

set -e

if [ "$1" == "setup" ]; then
  # Ensure the Go version in go.mod is valid
  sed -i 's/^go [0-9]\+\.[0-9]\+\.[0-9]\+$/go 1.20/' go.mod

  # Install Go dependencies
  go mod download
elif [ "$1" == "test" ]; then
  # Run tests unconditionally
  go test -v -race -coverprofile=coverage.out -timeout 30m ./...
else
  echo "Invalid argument. Use 'setup' to prepare the environment or 'test' to run tests."
  exit 1
fi