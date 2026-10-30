#!/bin/bash
set -e

# Disable git CRLF
git config --global core.autocrlf false

# Install dependencies
pnpm install

# Build packages
pnpm run build

# Run tests
pnpm run test:astro