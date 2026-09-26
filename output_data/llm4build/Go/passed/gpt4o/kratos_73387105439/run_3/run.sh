#!/bin/bash

# Start CockroachDB
docker create --name cockroach -p 26257:26257 cockroachdb/cockroach:latest-v25.4 start-single-node --insecure || true
docker start cockroach

# Pull Hydra (simulated by assuming it's available)
# docker pull oryd/hydra:v2.2.0

# Setup Go environment
export PATH="/usr/local/go/bin:${PATH}"

# Run go list
go list -json > go.list

# Run nancy (simulated by assuming it's available)
# nancy version v1.0.42

# Update apt-get
apt-get update

# Install Node.js dependencies
npm install

# Run golangci-lint
golangci-lint run --timeout 10m0s --only-new-issues=true

# Build Kratos
make install

# Run Go tests
make test-coverage