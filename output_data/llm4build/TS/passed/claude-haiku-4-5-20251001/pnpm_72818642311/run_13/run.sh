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

# Ensure git repository is properly configured before installing dependencies
echo "Configuring git repository..."
git config user.email "test@example.com" || true
git config user.name "Test User" || true

# Verify git is initialized
echo "Verifying git repository..."
git rev-parse --git-dir > /dev/null 2>&1 || (git init && git add . && git commit -m "Initial commit" --no-verify || true)

# Install project dependencies
echo "Installing dependencies..."
pnpm install

# Handle compiled artifacts if they exist
if [ -f "compiled.tar.gz" ]; then
  echo "Extracting compiled artifacts..."
  tar -xzf compiled.tar.gz
else
  echo "No compiled artifacts found, proceeding with tests..."
fi

# Run all tests
echo "Running tests..."
pnpm test 2>&1 || {
  EXIT_CODE=$?
  echo "Tests completed with exit code: $EXIT_CODE"
  exit $EXIT_CODE
}