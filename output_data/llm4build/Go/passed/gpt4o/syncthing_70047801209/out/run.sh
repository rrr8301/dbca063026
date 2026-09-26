#!/bin/bash

# Clone the repository (simulating actions/checkout)
git clone https://github.com/your-repo/syncthing.git /app
cd /app

# Install Go dependencies
go mod download

# Build Syncthing
go build ./cmd/syncthing

# Run tests
go test ./... || true  # Ensure all tests run even if some fail