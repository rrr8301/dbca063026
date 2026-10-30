#!/bin/bash
set -e

# Navigate to workspace
cd /workspace

# Setup pnpm environment and update PATH
export PNPM_HOME="/root/.local/share/pnpm"
export PATH="$PNPM_HOME:$PATH"

# Verify pnpm is available
echo "pnpm version:"
pnpm --version

# Verify npm version
echo "npm version:"
npm --version

# Install project dependencies
echo "Installing dependencies..."
pnpm install

# Ensure git repository is properly configured
echo "Configuring git repository..."
git config user.email "test@example.com" || true
git config user.name "Test User" || true

# Handle compiled artifacts if they exist
if [ -f "compiled.tar.gz" ]; then
  echo "Extracting compiled artifacts..."
  tar -xzf compiled.tar.gz
fi

# Run all tests
echo "Running tests..."
pnpm test