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

# Verify git is initialized and in a valid state
echo "Verifying git repository..."
if ! git rev-parse --git-dir > /dev/null 2>&1; then
  echo "Git repository not found, initializing..."
  git init --initial-branch=main
  git config user.email "test@example.com"
  git config user.name "Test User"
  git add .
  git commit -m "Initial commit" --no-verify || true
else
  echo "Git repository found and valid"
  # Ensure we have at least one commit for ghooks
  if ! git rev-parse HEAD > /dev/null 2>&1; then
    echo "No commits found, creating initial commit..."
    git add .
    git commit -m "Initial commit" --no-verify || true
  fi
fi

# Install project dependencies
echo "Installing dependencies..."
pnpm install

# Reinstall git hooks after pnpm install completes
echo "Installing git hooks..."
if [ -d "node_modules/ghooks" ]; then
  npm explore ghooks -- npm run install || true
fi

# Handle compiled artifacts if they exist
if [ -f "compiled.tar.gz" ]; then
  echo "Extracting compiled artifacts..."
  tar -xzf compiled.tar.gz
else
  echo "No compiled artifacts found, proceeding with tests..."
fi

# Run all tests with verbose output
echo "Running tests..."
pnpm test 2>&1 || EXIT_CODE=$?
EXIT_CODE=${EXIT_CODE:-0}
echo "Tests completed with exit code: $EXIT_CODE"
exit $EXIT_CODE