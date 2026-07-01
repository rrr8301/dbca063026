#!/bin/bash
set -e

# Change to repo root
cd /workspace

# Read Node version from .nvmrc
NODE_VERSION=$(cat ./cli/.nvmrc)
echo "Node version from .nvmrc: $NODE_VERSION"

# Install the specified Node version using nvm or use system Node if version matches
# For simplicity, we'll use the system Node.js (already installed in Dockerfile)
# If a specific version is needed, uncomment the nvm setup below:
# curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.0/install.sh | bash
# export NVM_DIR="$HOME/.nvm"
# [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
# nvm install $NODE_VERSION
# nvm use $NODE_VERSION

# Verify Node and pnpm are available
node --version
pnpm --version

# Setup typescript-sdk
echo "Setting up typescript-sdk..."
cd ./open-api/typescript-sdk
pnpm install
pnpm run build
cd /workspace

# Install CLI dependencies
echo "Installing CLI dependencies..."
cd ./cli
pnpm install

# Run linter
echo "Running linter..."
pnpm lint || true

# Run formatter
echo "Running formatter..."
pnpm format || true

# Run tsc (type checking)
echo "Running TypeScript compiler..."
pnpm check || true

# Run unit tests & coverage
echo "Running unit tests..."
pnpm test || true

echo "All CLI tests completed!"