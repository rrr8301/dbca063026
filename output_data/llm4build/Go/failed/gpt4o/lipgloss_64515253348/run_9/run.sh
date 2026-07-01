#!/bin/bash

# Ensure the Go version in go.mod matches the installed Go version
# Remove this line as it causes issues if go.mod is already correct
# go mod edit -go=1.20

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