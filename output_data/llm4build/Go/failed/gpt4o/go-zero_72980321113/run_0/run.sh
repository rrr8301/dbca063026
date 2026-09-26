#!/bin/bash

# Clone the repository
git clone <repository-url> /app
cd /app

# Install Go dependencies
go get -v -t -d ./...

# Lint the code
go vet -stdmethods=false $(go list ./...)
go mod tidy
if ! test -z "$(git status --porcelain)"; then
  echo "Please run 'go mod tidy'"
  exit 1
fi

# Run tests
go test -race -coverprofile=coverage.txt -covermode=atomic ./...