#!/bin/bash

set -e

# Navigate to the JS SDK directory
cd /workspace/apps/js-sdk/firecrawl

echo "=== Installing dependencies with pnpm ==="
pnpm install

echo "=== Building the project ==="
pnpm run build

echo "=== Running tests ==="
pnpm run test

echo "=== All tests completed ==="