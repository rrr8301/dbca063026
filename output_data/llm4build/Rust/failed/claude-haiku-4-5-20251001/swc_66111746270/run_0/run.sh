#!/bin/bash

set -e

# Enable error handling: continue on test failures but track exit code
test_exit_code=0

# Navigate to workspace
cd /workspace

# Enable corepack
corepack enable

# Install Node.js dependencies
echo "Installing Node.js dependencies..."
yarn install --frozen-lockfile || yarn install

# Install global test tools
echo "Installing global test tools..."
yarn global add jest@27 mocha || true

# Verify dependencies
echo "Verifying dependencies..."
yarn jest --version || echo "jest version check failed"
yarn mocha --version || echo "mocha version check failed"

# Configure execution cache
echo "Configuring execution cache..."
mkdir -p .swc-exec-cache
export SWC_ECMA_TESTING_CACHE_DIR=$(pwd)/.swc-exec-cache

# Run cargo test for swc package
echo "Running cargo tests for swc package..."
cargo test -p swc || test_exit_code=$?

# Exit with the test result code
exit $test_exit_code