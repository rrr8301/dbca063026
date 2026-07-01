#!/bin/bash

# Exit immediately if a command exits with a non-zero status
set -e

# Verify Go installation
go version

# Ensure goimports is available
if ! command -v goimports &> /dev/null; then
    echo "goimports could not be found"
    exit 1
fi

# Check and fix go.mod issues
if grep -q "toolchain" go.mod; then
    echo "Removing unsupported 'toolchain' directive from go.mod"
    sed -i '/toolchain/d' go.mod
fi

if grep -q "unknown block type: tool" go.mod; then
    echo "Removing unsupported block type 'tool' from go.mod"
    sed -i '/unknown block type: tool/d' go.mod
fi

# Ensure go.mod has a valid Go version
if ! grep -q '^go 1\.[0-9]\+$' go.mod; then
    echo "Adding valid Go version to go.mod"
    echo 'go 1.17' >> go.mod
fi

# Tidy up go.mod to ensure all dependencies are correct
go mod tidy || true

# Ensure goimports is installed
go install golang.org/x/tools/cmd/goimports@v0.1.5

# Build the project
make

# Run tests
set +e  # Continue executing even if some tests fail
make test-go