#!/bin/bash
set -e

# Activate nvm
export NVM_DIR=/opt/nvm
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"

# Navigate to workspace
cd /workspace

# Install dependencies
echo "Installing dependencies..."
pnpm install

# Build the project
echo "Building project..."
pnpm build

# Run typecheck
echo "Running typecheck..."
pnpm typecheck

# Run unit tests
echo "Running unit tests..."
pnpm vitest run test/unit || TEST_UNIT_FAILED=1

# Run minimal tests
echo "Running minimal tests..."
pnpm vitest run test/minimal || TEST_MINIMAL_FAILED=1

# Run vite tests
echo "Running vite tests..."
pnpm vitest run test/vite || TEST_VITE_FAILED=1

# Report test results
if [ "$TEST_UNIT_FAILED" = "1" ] || [ "$TEST_MINIMAL_FAILED" = "1" ] || [ "$TEST_VITE_FAILED" = "1" ]; then
    echo "Some tests failed"
    exit 1
fi

echo "All tests passed!"
exit 0