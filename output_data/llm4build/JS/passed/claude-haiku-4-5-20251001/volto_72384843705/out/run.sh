#!/bin/bash
set -e

# Navigate to workspace
cd /workspace

# Install project dependencies via make install
make install

# Build dependencies
make build-deps

# Run tests for the 'seven' package
pnpm --filter seven test