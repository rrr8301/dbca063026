#!/bin/bash
set -e

# Navigate to workspace
cd /workspace

# Setup pnpm environment and update PATH
export PNPM_HOME="/root/.local/share/pnpm"
export PATH="$PNPM_HOME:$PATH"

# Verify pnpm is available
pnpm --version

# Verify npm version
npm --version

# Install project dependencies
pnpm install

# Handle compiled artifacts if they exist
if [ -f "compiled.tar.gz" ]; then
  echo "Extracting compiled artifacts..."
  tar -xzf compiled.tar.gz
else
  echo "Note: compiled.tar.gz not found. Building from source..."
  # Build the monorepo packages
  pnpm run build || true
fi

# Run all tests
echo "Running tests..."
pnpm test