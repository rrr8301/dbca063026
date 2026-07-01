#!/bin/bash

# Activate environment
export PATH="/home/testuser/.bun/bin:$PATH"

# Install project dependencies
pnpm install

# Automatically approve all build scripts
pnpm approve-builds --all

# Run tests with coverage
for package in $PACKAGES; do
  echo "::group::Testing $package"
  bun run --filter $package test:coverage || exit 1
  echo "::endgroup::"
done