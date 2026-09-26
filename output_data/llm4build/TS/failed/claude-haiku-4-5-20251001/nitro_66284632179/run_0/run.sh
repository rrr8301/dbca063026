#!/bin/bash

set -e

# Print commands for debugging
set -x

# Navigate to workspace
cd /workspace

# Run stub and lint
echo "Running stub and lint..."
pnpm stub && pnpm lint
LINT_EXIT=$?

# Run typecheck
echo "Running typecheck..."
pnpm typecheck
TYPECHECK_EXIT=$?

# Run unit tests
echo "Running unit tests..."
pnpm vitest run test/unit
UNIT_EXIT=$?

# Run minimal tests
echo "Running minimal tests..."
pnpm vitest run test/minimal
MINIMAL_EXIT=$?

# Collect all exit codes
FAILED=0
[ $LINT_EXIT -ne 0 ] && FAILED=1
[ $TYPECHECK_EXIT -ne 0 ] && FAILED=1
[ $UNIT_EXIT -ne 0 ] && FAILED=1
[ $MINIMAL_EXIT -ne 0 ] && FAILED=1

# Exit with failure if any step failed
exit $FAILED