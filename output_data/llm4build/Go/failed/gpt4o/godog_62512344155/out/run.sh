#!/bin/bash

# Clone the repository (assuming the repo URL is known)
# git clone <repository-url> /app

# Navigate to the app directory
cd /app

# Install Go dependencies
go mod download

# Run gofmt
gofmt -d -e . 2>&1 | tee outfile && test -z "$(cat outfile)" && rm outfile

# Run go vet
go vet ./...
cd _examples && go vet ./... && cd ..

# Run go test
go test -v -race -coverprofile=coverage.txt -covermode=atomic ./...
cd _examples && go test -v -race ./... && cd ..

# Install and run godog
go install ./cmd/godog
godog -f progress --strict