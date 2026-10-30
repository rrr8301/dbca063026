#!/bin/bash

set -e

# Enable error handling: continue on test failures but track exit code
TEST_EXIT_CODE=0

echo "=== Starting freeCodeCamp Test Suite ==="

# Clone repository if not already present
if [ ! -d "/workspace/.git" ]; then
    echo "Cloning repository..."
    cd /workspace
    git clone --recursive https://github.com/freeCodeCamp/freeCodeCamp.git .
else
    echo "Repository already present, updating submodules..."
    cd /workspace
    git submodule update --init --recursive
fi

# Load environment variables from sample.env
if [ -f "/workspace/sample.env" ]; then
    echo "Loading environment variables from sample.env..."
    set -a
    source /workspace/sample.env
    set +a
    cat /workspace/sample.env
else
    echo "Warning: sample.env not found"
fi

# Start services via docker-compose
if [ -f "/workspace/docker/docker-compose.yml" ]; then
    echo "Starting services via docker-compose..."
    docker-compose -f /workspace/docker/docker-compose.yml up -d || true
    sleep 5
else
    echo "Warning: docker-compose.yml not found at /workspace/docker/docker-compose.yml"
fi

# Install pnpm dependencies
echo "Installing pnpm dependencies..."
cd /workspace
pnpm install || { echo "pnpm install failed"; TEST_EXIT_CODE=1; }

# Install Chrome for Puppeteer
echo "Installing Chrome for Puppeteer..."
pnpm -F=curriculum install-puppeteer || { echo "Puppeteer installation failed"; TEST_EXIT_CODE=1; }

# Run tests
echo "Running test suite..."
pnpm test || { echo "Tests failed with exit code $?"; TEST_EXIT_CODE=1; }

# Cleanup
echo "Cleaning up..."
docker-compose -f /workspace/docker/docker-compose.yml down 2>/dev/null || true

echo "=== Test Suite Complete ==="
exit $TEST_EXIT_CODE