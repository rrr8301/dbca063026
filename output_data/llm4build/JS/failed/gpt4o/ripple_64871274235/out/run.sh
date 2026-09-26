#!/bin/bash

# Install project dependencies
pnpm install --prod false --frozen-lockfile

# Build CLI and eslint-parser
pnpm --filter ./packages/cli build
pnpm --filter ./packages/eslint-parser build

# Run tests and ensure all tests are executed
set +e
pnpm test
EXIT_CODE=$?
set -e

# Exit with the test command's exit code
exit $EXIT_CODE