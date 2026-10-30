#!/bin/bash

# Ensure project dependencies are installed
pnpm install

# Build the project
pnpm run build

# Run tests
pnpm run test:ci || true

# Run example tests
pnpm run test:examples || true