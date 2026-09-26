#!/bin/bash

# Ensure the Go version in go.mod matches the installed Go version
sed -i 's/go 1.24.2/go 1.20/' go.mod

# Tidy Go modules
go mod tidy

# Check for changes
git diff --exit-code

# Build the project
go build ./...

# Run tests
go test ./...

# Complete job
echo "Job completed"