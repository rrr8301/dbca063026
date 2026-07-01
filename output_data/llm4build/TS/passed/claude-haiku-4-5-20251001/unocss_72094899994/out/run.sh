#!/bin/bash

set -e

# Print commands for debugging
set -x

# Install dependencies
pnpm install

# Build the project
pnpm build

# Run tests (continue even if tests fail)
pnpm test || TEST_FAILED=1

# Run typecheck (continue even if typecheck fails)
pnpm typecheck || TYPECHECK_FAILED=1

# Exit with failure if any test suite failed
if [ "$TEST_FAILED" = "1" ] || [ "$TYPECHECK_FAILED" = "1" ]; then
    exit 1
fi

exit 0