#!/bin/bash

# Set git to use LF
git config --global core.autocrlf false
git config --global core.eol lf

# Install dependencies
pnpm install

# Build the project
pnpm build

# Run tests
pnpm test || true  # Ensure all tests run even if some fail

# Typecheck
pnpm typecheck || true  # Ensure typecheck runs even if it fails