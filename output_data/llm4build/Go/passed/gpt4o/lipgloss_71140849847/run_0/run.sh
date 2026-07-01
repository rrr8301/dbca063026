#!/bin/bash

# Set Go environment variables
export PATH="/usr/local/go/bin:${PATH}"

# Tidy Go modules
go mod tidy

# Check for changes
git diff --exit-code

# Build the project
go build ./...

# Run tests
go test ./...

# Post steps
echo "Post Install Go step"
echo "Post Checkout code step"
echo "Complete job step"