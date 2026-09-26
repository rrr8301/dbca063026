#!/bin/bash

set -e

# Enable corepack
corepack enable

# Install dependencies with yarn
echo "Installing dependencies..."
yarn install --immutable --inline-builds \
  --env YARN_ENABLE_GLOBAL_CACHE=false \
  --env YARN_ENABLE_MIRROR=false \
  --env YARN_NM_MODE=hardlinks-local \
  --env YARN_INSTALL_STATE_PATH=.yarn/ci-cache/install-state.gz

# Build monorepo
echo "Building monorepo..."
yarn nx run-many --targets build --nx-ignore-cycles --skip-nx-cache

# Run frontend tests
echo "Running frontend tests..."
yarn nx run-many --target=test:front --nx-ignore-cycles -- --runInBand --coverage

echo "Tests completed successfully!"