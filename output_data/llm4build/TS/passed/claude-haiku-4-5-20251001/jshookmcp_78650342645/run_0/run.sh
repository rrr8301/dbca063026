#!/bin/bash
set -e

# Activate nvm
export NVM_DIR=$HOME/.nvm
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"

# Verify Node.js and pnpm are available
node --version
pnpm --version

# Install dependencies with frozen lockfile
echo "Installing dependencies..."
pnpm install --frozen-lockfile

# Generate registry index
echo "Generating registry index..."
node scripts/generate-domains-index.mjs

# Run linters & formatters
echo "Running linters..."
pnpm run lint

echo "Checking formatting..."
pnpm run format:check

echo "Running typecheck..."
pnpm run typecheck

# Run unit tests with coverage
echo "Running unit tests with coverage..."
pnpm run test:coverage

# Build project
echo "Building project..."
pnpm run build

echo "All checks and tests completed successfully!"