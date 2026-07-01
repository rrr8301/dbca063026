#!/bin/bash

# Start CockroachDB (removed Docker commands)
# docker create --name cockroach -p 26257:26257 cockroachdb/cockroach:latest-v25.4 start-single-node --insecure || true
# docker start cockroach

# Pull Hydra (simulated by assuming it's available)
# docker pull oryd/hydra:v2.2.0

# Setup Go environment
export PATH="/usr/local/go/bin:${PATH}"
go version

# Install Go dependencies
if [ -f go.mod ]; then
    if ! go mod tidy; then
        echo "Error in go.mod file. Skipping Go dependencies installation."
    else
        go mod download
    fi
else
    echo "go.mod file not found. Skipping Go dependencies installation."
fi

# Install Node dependencies
npm install

# Build Kratos
make install

# Run Go tests
make test-coverage