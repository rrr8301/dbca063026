#!/bin/bash

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