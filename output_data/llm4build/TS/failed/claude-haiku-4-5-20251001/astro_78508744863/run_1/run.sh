#!/bin/bash
set -e

# Disable git CRLF
git config --global core.autocrlf false

# Ensure Node.js is available
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
nvm use 22

# Verify Node.js and pnpm are available
node --version
npm --version
pnpm --version

# Install dependencies
echo "Installing dependencies..."
pnpm install

# Build packages
echo "Building packages..."
pnpm run build

# Run integration tests
echo "Running integration tests..."
TURBO_LOG_ORDER=stream pnpm run test:integrations

echo "All tests completed successfully!"