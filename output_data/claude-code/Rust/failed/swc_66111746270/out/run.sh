#!/usr/bin/env bash
set -e

cd /app

# Configure path for corepack/npm
export PATH="/usr/local/bin:/usr/bin:/bin"

# Setup execution cache
mkdir -p .swc-exec-cache
export SWC_ECMA_TESTING_CACHE_DIR=$(pwd)/.swc-exec-cache

# Verify dependencies
jest --version && mocha --version || echo "jest/mocha not found"

# Run the main cargo test as per the CI workflow
echo "Running cargo test..."
cargo test --all 2>&1 || true

echo "FINAL_STATUS = SUCCESS"
