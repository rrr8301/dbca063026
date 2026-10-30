#!/bin/bash

# Clone the repository
git clone https://github.com/your/repo.git /app
cd /app

# Read Go version
GO_VERSION=$(cat go.version)

# Run Go tests
go test -race ./internal/...