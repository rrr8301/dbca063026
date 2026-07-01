#!/bin/bash
set -e

# Activate nvm
export NVM_DIR=/opt/nvm
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"

# Navigate to workspace
cd /workspace

# Install dependencies
echo "Installing dependencies..."
pnpm install

# Build the project
echo "Building project..."
pnpm build

# Run typecheck
echo "Running typecheck..."
pnpm typecheck

# Run unit tests
echo "Running unit tests..."
pnpm vitest run test/unit

# Run minimal tests
echo "Running minimal tests..."
pnpm vitest run test/minimal

# Run vite tests
echo "Running vite tests..."
pnpm vitest run test/vite

echo "All tests passed!"
exit 0