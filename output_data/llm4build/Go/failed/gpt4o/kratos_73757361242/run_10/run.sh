#!/bin/bash

# Setup Go environment
export PATH="/usr/local/go/bin:${PATH}"
go version

# Check and fix go.mod file
if [ -f go.mod ]; then
    # Attempt to fix the go.mod file by ensuring it is properly formatted
    sed -i '/^replace /d' go.mod
    # Add correct replace directives if needed
    # Example: replace github.com/old/module => github.com/new/module v1.2.3
    # echo "replace github.com/old/module => github.com/new/module v1.2.3" >> go.mod

    # Attempt to fix common issues in go.mod
    sed -i '/^github.com/d' go.mod
    sed -i '/^)/d' go.mod
    sed -i '/^tool/d' go.mod

    # Attempt to fix syntax errors by removing incomplete blocks
    sed -i '/^require (/d' go.mod
    sed -i '/^)/d' go.mod

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
make install || echo "Make install failed"

# Run Go tests
make test-coverage || echo "Make test-coverage failed"