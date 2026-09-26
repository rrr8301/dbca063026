#!/bin/bash

# Activate Go environment
export PATH="/usr/local/go/bin:${PATH}"

# Ensure the Go version in go.mod is compatible
sed -i 's/^go .*/go 1.21/' go.mod

# Update go.mod and go.sum
go mod tidy

# Check if the template file exists, if not, create a placeholder
TEMPLATE_FILE="../../../docs/docs/configuration/alpha_config.md.tmpl"
if [ ! -f "$TEMPLATE_FILE" ]; then
    echo "Creating placeholder for missing template file: $TEMPLATE_FILE"
    mkdir -p "$(dirname "$TEMPLATE_FILE")"
    touch "$TEMPLATE_FILE"
fi

# Install project dependencies
make verify-generate

# Run lint
make lint

# Build the project
make build

# Enable CGO for tests that require it
export CGO_ENABLED=1

# Run tests
make test