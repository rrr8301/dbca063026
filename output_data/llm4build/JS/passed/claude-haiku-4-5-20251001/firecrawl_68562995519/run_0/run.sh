#!/bin/bash
set -e

# Navigate to the JS SDK directory
cd /workspace/apps/js-sdk/firecrawl

# Install dependencies
pnpm install

# Build
pnpm run build

# Run tests
pnpm run test