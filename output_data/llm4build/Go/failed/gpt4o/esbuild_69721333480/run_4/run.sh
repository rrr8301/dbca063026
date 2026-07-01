#!/bin/bash

# Navigate to the app directory
cd /app

# Enable CGO
export CGO_ENABLED=1

# Read Go version
GO_VERSION=$(cat go.version)

# Run Go tests
go test -race ./internal/...