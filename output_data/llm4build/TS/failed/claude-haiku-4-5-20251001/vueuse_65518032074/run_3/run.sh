#!/bin/bash

set -e

# Print commands for debugging
set -x

# Change to workspace directory
cd /workspace

# Install dependencies using nci (from @antfu/ni)
nci

# Install Playwright browsers with system dependencies
# The --with-deps flag automatically installs required system packages
pnpm exec playwright install --with-deps

# Build the project
nr build

# Typecheck
nr typecheck

# Run unit tests with coverage
echo "Running unit tests with coverage..."
pnpm run test:cov

# Run browser tests
echo "Running browser tests..."
pnpm run test:browser

# Run server tests
echo "Running server tests..."
pnpm run test:server

# Run attw tests
echo "Running attw tests..."
pnpm run test:attw

echo ""
echo "========== ALL TESTS PASSED =========="