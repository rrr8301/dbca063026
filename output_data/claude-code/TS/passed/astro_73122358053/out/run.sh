#!/usr/bin/env bash
set -e

cd /app

# Disable git crlf
git config --global core.autocrlf false

# Install dependencies
pnpm install

# Build packages
pnpm run build

# Run the astro test suite
pnpm run test:astro

echo "FINAL_STATUS = SUCCESS"
