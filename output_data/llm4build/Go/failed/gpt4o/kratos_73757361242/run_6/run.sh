#!/bin/bash

# Setup Go environment
export PATH="/usr/local/go/bin:${PATH}"
go version

# Check and fix go.mod file
if [ -f go.mod ]; then
    # Attempt to fix the go.mod file by removing the problematic lines
    sed -i '/^github.com\/cortesi\/modd\/cmd\/modd/d' go.mod
    sed -i '/^github.com\/go-swagger\/go-swagger\/cmd\/swagger/d' go.mod
    sed -i '/^github.com\/mailhog\/MailHog/d' go.mod
    sed -i '/^github.com\/mikefarah\/yq\/v4/d' go.mod
    sed -i '/^golang.org\/x\/tools\/cmd\/goimports/d' go.mod
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
make install

# Run Go tests
make test-coverage