#!/bin/bash

# Exit immediately if a command exits with a non-zero status
set -e

# Get dependencies
go get -v -t -d ./...

# Lint the code
go vet -stdmethods=false $(go list ./...)
go mod tidy
if ! test -z "$(git status --porcelain)"; then
  echo "Please run 'go mod tidy'"
  exit 1
fi

# Run tests with race detection and coverage
go test -race -coverprofile=coverage.txt -covermode=atomic ./...

# Note: Codecov step is skipped