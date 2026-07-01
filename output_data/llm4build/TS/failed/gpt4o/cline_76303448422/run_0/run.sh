#!/bin/bash

# Activate Bun environment
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"

# Install project dependencies
bun install

# Build SDK
bun run build:sdk

# Build CLI
bun -F @cline/cli build

# Run Tests
bun run test

# Smoke test SQLite under Node
bun scripts/ci-node-smoke.ts

# Run TUI e2e tests
bun -F @cline/cli test:e2e:cli:tui

# Verify packages are publishable
bun scripts/check-publish.ts