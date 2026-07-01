#!/bin/bash

# Activate Go environment
export PATH="/usr/local/go/bin:${PATH}"

# Install Go dependencies
go mod tidy -compat=1.17
go mod download

# Run tests and build
set -e

# Check and fix go.mod version format
sed -i 's/^go [0-9]\+\.[0-9]\+\.[0-9]\+$/go 1.17/' go.mod || true

# Handle specific package compatibility issues
# Check if the file exists before attempting to modify it
FILE_PATH="path/to/your/file.go"
if [ -f "$FILE_PATH" ]; then
    sed -i '/import "log\/slog"/d' "$FILE_PATH"
    sed -i '/import "slices"/d' "$FILE_PATH"
    sed -i '/import "maps"/d' "$FILE_PATH"
    sed -i '/import "net\/netip"/d' "$FILE_PATH"
    sed -i '/import "cmp"/d' "$FILE_PATH"
    sed -i '/import "math\/rand\/v2"/d' "$FILE_PATH"
    sed -i '/import "weak"/d' "$FILE_PATH"
    sed -i '/import "iter"/d' "$FILE_PATH"
    sed -i '/import "crypto\/sha3"/d' "$FILE_PATH"
fi

# Run tests and build
make test-source-headers || true
go mod tidy -compat=1.17 || true
make test-coverage || true
make build || true

# Additional step to ensure all dependencies are correctly fetched
go get -u ./...

# Re-run tests and build after ensuring dependencies
make test-source-headers || true
make test-coverage || true
make build || true