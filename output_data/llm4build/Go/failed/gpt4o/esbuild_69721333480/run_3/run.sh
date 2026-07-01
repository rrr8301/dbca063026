#!/bin/bash

# Navigate to the app directory
cd /app

# Read Go version
GO_VERSION=$(cat go.version)

# Run Go tests
go test -race ./internal/...