#!/bin/bash
set -e

# Print Go version for debugging
go version

# Download Go module dependencies
go mod download -x

# Run the test command
go run ./cmd/task test