#!/bin/bash

# Setup Go environment
export PATH="/usr/local/go/bin:${PATH}"
go version

# Check and fix go.mod file
if [ -f go.mod ]; then
    # Placeholder: Manually inspect and fix the go.mod file
    echo "Please inspect and fix the go.mod file manually."
    # Attempt to fix the go.mod file by running go mod tidy
    if ! go mod tidy; then
        echo "Error in go.mod file. Skipping Go dependencies installation."
    else
        go mod download
    fi
else
    echo "go.mod file not found. Skipping Go dependencies installation."
fi

# Install Node dependencies
npm install

# Ensure Git repository is set up
if [ ! -d .git ]; then
    git init
    git add .
    git commit -m "Initial commit"
fi

# Build Kratos
if ! make install; then
    echo "Make install failed"
fi

# Run Go tests
if ! make test-coverage; then
    echo "Make test-coverage failed"
fi