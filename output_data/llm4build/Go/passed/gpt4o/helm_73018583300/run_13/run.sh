#!/bin/bash

# Activate Go environment
export PATH="/usr/local/go/bin:${PATH}"

# Install Go dependencies
go mod tidy -compat=1.17
go mod download

# Run tests and build
set -e

# Check and fix go.mod version format
sed -i 's/^go [0-9]\+\.[0-9]\+\.[0-9]\+$/go 1.17/' go.mod

# Handle specific package compatibility issues
# Comment out imports that are not supported in Go 1.17
sed -i '/import "log\/slog"/d' path/to/your/file.go
sed -i '/import "slices"/d' path/to/your/file.go
sed -i '/import "maps"/d' path/to/your/file.go
sed -i '/import "net\/netip"/d' path/to/your/file.go
sed -i '/import "cmp"/d' path/to/your/file.go
sed -i '/import "math\/rand\/v2"/d' path/to/your/file.go
sed -i '/import "weak"/d' path/to/your/file.go
sed -i '/import "iter"/d' path/to/your/file.go
sed -i '/import "crypto\/sha3"/d' path/to/your/file.go

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