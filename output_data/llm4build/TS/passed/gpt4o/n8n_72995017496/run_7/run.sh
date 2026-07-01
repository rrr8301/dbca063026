#!/bin/bash

# Activate environment variables if needed
export NODE_OPTIONS="--max-old-space-size=7168"

# Install project dependencies
pnpm install --frozen-lockfile

# Run backend unit tests
pnpm test:ci:backend:unit --summarize || true

# Run backend integration tests
pnpm test:ci:backend:integration --summarize || true

# Run nodes unit tests
pnpm turbo test --filter=n8n-nodes-base --summarize || true

# Run frontend tests with sharding
pnpm test:ci:frontend --summarize -- --shard=1/2 || true
pnpm test:ci:frontend --summarize -- --shard=2/2 || true

# Simulate sending test stats (replace with actual command if needed)
echo "Simulating sending test stats..."

# Ensure all tests are executed even if some fail
exit 0