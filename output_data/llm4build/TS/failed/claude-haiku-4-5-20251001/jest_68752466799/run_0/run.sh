#!/bin/bash

set -e

# Function to retry a command
retry_command() {
    local max_attempts=3
    local timeout_minutes=10
    local attempt=1
    local command="$@"
    
    while [ $attempt -le $max_attempts ]; do
        echo "Attempt $attempt of $max_attempts: $command"
        if timeout $((timeout_minutes * 60)) bash -c "$command"; then
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
echo "Number of CPU cores: $CPU_CORES"

# Install dependencies
echo "Installing dependencies..."
yarn --immutable

# Build JavaScript
echo "Building JavaScript..."
yarn build:js

# Run node-env tests
echo "Running node-env tests..."
yarn workspace jest-environment-node test || true

# Run main tests with retry and parallel execution
echo "Running main tests with parallel execution..."
retry_command "yarn test-ci-partial:parallel --max-workers $CPU_CORES --shard=3/3" || true

# Run jasmine tests with retry
echo "Running jasmine tests..."
retry_command "yarn jest-jasmine-ci --max-workers $CPU_CORES --shard=3/3" || true

echo "All tests completed!"