#!/bin/bash

set -e

# Exit on error but continue running tests
TEST_FAILED=0

# Setup environment
echo "Setting up environment..."
if [ -f .env.example ]; then
    cp .env.example .env
    echo ".env file created from .env.example"
else
    echo "Warning: .env.example not found"
fi

# Set environment variables for installation
export DATABASE_URL="${DATABASE_URL:-postgresql://postgres:testpass@localhost:5432/hoppscotch}"
export DATA_ENCRYPTION_KEY="${DATA_ENCRYPTION_KEY:-12345678901234567890123456789012}"

# Install dependencies
echo "Installing dependencies with pnpm..."
pnpm install || { echo "pnpm install failed"; TEST_FAILED=1; }

# Run tests
echo "Running tests..."
pnpm test || { echo "Tests failed"; TEST_FAILED=1; }

# Exit with appropriate code
if [ $TEST_FAILED -eq 1 ]; then
    echo "Test execution completed with failures"
    exit 1
else
    echo "All tests passed successfully"
    exit 0
fi