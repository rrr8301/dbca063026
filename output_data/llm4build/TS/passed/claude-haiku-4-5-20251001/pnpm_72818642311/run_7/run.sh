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

# Handle compiled artifacts if they exist
if [ -f "compiled.tar.gz" ]; then
  echo "Extracting compiled artifacts..."
  tar -xzf compiled.tar.gz
fi

# Determine test scope
echo "Determining test scope..."
pnpm test:scope || true

# Run all tests
echo "Running tests..."
pnpm test