#!/bin/bash

# Tidy Go modules
go mod tidy

# Check for changes
git diff --exit-code

# Build the project
GOOS=linux GOARCH=amd64 go build ./...

# Run tests
go test ./...

# Complete job
echo "Job completed"