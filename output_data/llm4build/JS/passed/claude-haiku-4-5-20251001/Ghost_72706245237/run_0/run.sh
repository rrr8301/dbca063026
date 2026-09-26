#!/bin/bash
set -e

# Set environment variables for test execution
export FORCE_COLOR=0
export DISABLE_V8_COMPILE_CACHE=1
export GHOST_UNIT_TEST_VARIANT=ci
export NX_SKIP_LOG_GROUPING=true
export logging__level=fatal

# Navigate to workspace
cd /workspace

# Install dependencies with frozen lockfile
echo "Installing dependencies..."
pnpm install --frozen-lockfile --force

# Run unit tests
echo "Running unit tests..."
pnpm nx run-many -t test:unit

# Check for unexpected file changes
echo "Checking for unexpected file changes..."
if [ -n "$(git status --porcelain)" ]; then
    echo "Tests generated unexpected file changes. Commit them before merging:"
    git status
    git diff
    exit 1
fi

echo "Unit tests completed successfully!"