#!/bin/bash

# Navigate to the project directory
cd /workspace/enterprise/poa

# Ensure the Go version in go.mod is valid
sed -i 's/^go 1\.25\.9$/go 1.20/' go.mod

# Install Go dependencies
go mod download

# Run tests unconditionally
go test -v -race -coverprofile=coverage.out -timeout 30m ./...