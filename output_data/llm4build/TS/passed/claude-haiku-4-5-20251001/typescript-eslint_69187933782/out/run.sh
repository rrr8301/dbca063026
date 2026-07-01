#!/bin/bash

set -e

# Enable error handling: continue on test failures but track exit code
TEST_EXIT_CODE=0

# Set environment variables
export CI=true
export NX_VERBOSE_LOGGING=false
export NX_CI_EXECUTION_ENV='ubuntu-latest'
export HUSKY=0
export SKIP_POSTINSTALL=true

echo "=== Installing dependencies ==="
pnpm install --frozen-lockfile
pnpm run check-clean-workspace-after-install

echo "=== Building AST Spec ==="
pnpm exec nx run types:build

echo "=== Building project ==="
pnpm exec nx run-many --target=build --parallel --exclude=website --exclude=website-eslint || true

echo "=== Running unit tests for eslint-plugin ==="
pnpm exec nx test eslint-plugin -- --shard=4/4 || TEST_EXIT_CODE=$?

echo "=== Test execution completed ==="
exit $TEST_EXIT_CODE