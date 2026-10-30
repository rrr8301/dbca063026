#!/bin/bash

set -e

# Function to retry a command
retry_command() {
    local max_attempts=3
    local timeout_minutes=10
    local attempt=1
    
    while [ $attempt -le $max_attempts ]; do
        echo "Attempt $attempt of $max_attempts..."
        if timeout $((timeout_minutes * 60)) "$@"; then
            return 0
        fi
        attempt=$((attempt + 1))
        if [ $attempt -le $max_attempts ]; then
            echo "Command failed, retrying..."
            sleep 5
        fi
    done
    
    echo "Command failed after $max_attempts attempts"
    return 1
}

# Get number of CPU cores
CPU_CORES=$(nproc)
echo "CPU cores available: $CPU_CORES"

# Install dependencies
echo "Installing dependencies..."
yarn --immutable

# Build JavaScript
echo "Building JavaScript..."
yarn build:js

# Run tests with coverage (shard 3/4)
echo "Running tests with coverage (shard 3/4)..."
retry_command yarn jest-coverage \
    --color \
    --config jest.config.ci.mjs \
    --max-workers "$CPU_CORES" \
    --shard=3/4

# Map coverage
echo "Mapping coverage..."
node ./scripts/mapCoverage.mjs || true

echo "Test execution completed"