#!/bin/bash

# Activate Bun environment
export BUN_INSTALL="/usr/local/bun"
export PATH="$BUN_INSTALL/bin:$PATH"

# Source Bun environment if needed
source "$BUN_INSTALL/env" || true

# Install project dependencies
bun install

# Build SDK
bun run build:sdk

# Build CLI
bun -F @cline/cli build

# Run Tests
bun run test

# Smoke test SQLite under Node
bun run scripts/ci-node-smoke.ts

# Run TUI e2e tests
bun -F @cline/cli test:e2e:cli:tui

# Verify packages are publishable
bun run scripts/check-publish.ts