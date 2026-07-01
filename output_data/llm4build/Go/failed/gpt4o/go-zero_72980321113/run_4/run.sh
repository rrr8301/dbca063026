#!/bin/bash

# Clone the repository using HTTPS
# Ensure that the repository URL is correct and accessible
# If authentication is required, consider using a personal access token or SSH key
git clone https://github.com/your-username/your-repository.git /app || {
  echo "Failed to clone repository. Please check the repository URL and authentication."
  exit 1
}

cd /app

# Check if go.mod exists, if not, initialize a new module
if [ ! -f go.mod ]; then
  go mod init your-module-name
fi

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