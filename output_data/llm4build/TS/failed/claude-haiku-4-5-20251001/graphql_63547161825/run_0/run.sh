#!/bin/bash

set -e

# Enable Corepack
corepack enable

# Set up Node.js (already done by base image, but ensure corepack is enabled)
corepack enable

# Install dependencies with yarn
# GITHUB_TOKEN can be passed as build arg or env var for rate limiting
export GITHUB_TOKEN="${GITHUB_TOKEN:-}"
yarn install --inline-builds && yarn --cwd packages/create-redwood-rsc-app install --inline-builds

# Build the project
yarn build

# Get number of CPU cores for test parallelization
CPU_CORES=$(nproc)

# Run tests
# Ensure all tests run even if some fail
yarn test-ci --minWorkers=1 --maxWorkers="$CPU_CORES" || TEST_EXIT_CODE=$?

# Exit with test result code if tests failed
if [ ! -z "$TEST_EXIT_CODE" ]; then
  exit $TEST_EXIT_CODE
fi

exit 0