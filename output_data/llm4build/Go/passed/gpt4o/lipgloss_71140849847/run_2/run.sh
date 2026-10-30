#!/bin/bash

# Set Go environment variables
export PATH="/usr/local/go/bin:${PATH}"

# Ensure go.mod is valid
if ! grep -q "module " go.mod; then
    echo "module example.com/myapp" > go.mod
fi

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