#!/bin/bash

# Activate environment
export PATH="/home/testuser/.bun/bin:$PATH"

# Install project dependencies
pnpm install

# Run tests with coverage
for package in $PACKAGES; do
  echo "::group::Testing $package"
  bun run --filter $package test:coverage
  echo "::endgroup::"
done