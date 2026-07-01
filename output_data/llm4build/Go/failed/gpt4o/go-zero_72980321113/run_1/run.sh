#!/bin/bash

# Clone the repository
git clone https://github.com/your-username/your-repository.git /app
cd /app

# Ensure go.mod specifies a compatible Go version
sed -i 's/go 1.24.0/go 1.17/' go.mod

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