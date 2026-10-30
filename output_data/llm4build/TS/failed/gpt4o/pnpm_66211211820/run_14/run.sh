#!/bin/bash

# Configure Git
git config --global core.autocrlf false
git config --global user.name "xyz"
git config --global user.email "x@y.z"

# Verify npm
npm --version

# Install dependencies
pnpm install

# Check if compiled.tar.gz exists before attempting to extract
if [ -f "compiled.tar.gz" ]; then
  tar -xzf compiled.tar.gz
else
  echo "Warning: compiled.tar.gz not found. Skipping extraction."
fi

# Determine test scope
if [[ "$(git rev-parse --abbrev-ref HEAD)" == "main" || "$(git rev-parse --abbrev-ref HEAD)" == "chore/update-lockfile" ]]; then
  script="ci:test-all"
else
  git remote set-branches --add origin main && git fetch origin main --depth=1
  if [ -n "$(git diff --name-only origin/main HEAD -- pnpm-workspace.yaml)" ]; then
    script="ci:test-all"
  else
    script="ci:test-branch"
  fi
fi

# Run tests
PNPM_WORKERS=3 pnpm run $script || true