#!/bin/bash
set -e

# Configure git for LF line endings
git config --global core.autocrlf false
git config --global core.eol lf

# Install dependencies
pnpm install

# Build
pnpm build

# Test
pnpm test