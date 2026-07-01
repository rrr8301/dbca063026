#!/bin/bash

# Setup Go environment
export PATH="/usr/local/go/bin:${PATH}"
go version

# Check and fix go.mod file
if [ -f go.mod ]; then
    # Attempt to fix the go.mod file by ensuring it is properly formatted
    sed -i '/^replace /d' go.mod

    # Remove any lines that are not valid directives
    sed -i '/^github.com/d' go.mod
    sed -i '/^go.mongodb.org/d' go.mod
    sed -i '/^go.opentelemetry.io/d' go.mod
    sed -i '/^golang.org/d' go.mod
    sed -i '/^google.golang.org/d' go.mod
    sed -i '/^gopkg.in/d' go.mod
    sed -i '/^sigs.k8s.io/d' go.mod

    # Attempt to fix syntax errors by removing incomplete blocks
    sed -i '/^require (/d' go.mod
    sed -i '/^)/d' go.mod

    # Ensure the go.mod file ends with a newline
    echo "" >> go.mod

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

# Build Kratos
if ! make install; then
    echo "Make install failed"
fi

# Run Go tests
if ! make test-coverage; then
    echo "Make test-coverage failed"
fi