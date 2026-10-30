#!/bin/bash

# Configure Git
git config --global core.autocrlf false
git config --global user.name "xyz"
git config --global user.email "x@y.z"

# Setup Node.js version
pnpm runtime -g set node 22.13.0

# Verify npm
npm --version

# Install dependencies
pnpm install

# Simulate downloading and extracting compiled artifacts
# Assuming compiled.tar.gz is available in the current directory
tar -xzf compiled.tar.gz

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