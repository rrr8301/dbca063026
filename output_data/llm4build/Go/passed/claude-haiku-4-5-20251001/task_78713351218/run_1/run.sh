#!/bin/bash
set -e

# Print Go version for debugging
go version

# Download Go module dependencies
go mod download -x

# Install pnpm dependencies for website (if needed by task)
if [ -f "website/pnpm-lock.yaml" ]; then
    cd website
    pnpm install --frozen-lockfile
    cd ..
fi

# Run the test command
go run ./cmd/task test