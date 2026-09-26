#!/bin/bash

# Activate Bun environment
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"

# Install project dependencies
bun install --frozen-lockfile

# Run formatting, linting, and tests
set +e  # Continue execution even if some commands fail
bun run format
bun run lint
bun run editorconfig-checker -format github-actions
bun run build
bun run test
set -e  # Re-enable exit on error