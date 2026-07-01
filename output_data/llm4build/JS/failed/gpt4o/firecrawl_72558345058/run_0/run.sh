#!/bin/bash

# Navigate to the project directory
cd /app/apps/js-sdk/firecrawl

# Install project dependencies
pnpm install

# Build the project
pnpm run build

# Run tests
pnpm run test || true  # Ensure all tests run even if some fail