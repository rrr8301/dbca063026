#!/bin/bash

set -e

# Enable corepack
corepack enable

# Install dependencies with yarn
echo "Installing dependencies..."
YARN_ENABLE_GLOBAL_CACHE=false \
YARN_ENABLE_MIRROR=false \
YARN_NM_MODE=hardlinks-local \
YARN_INSTALL_STATE_PATH=.yarn/ci-cache/install-state.gz \
yarn install --immutable --inline-builds

# Build monorepo
echo "Building monorepo..."
yarn nx run-many --targets build --nx-ignore-cycles --skip-nx-cache

# Run frontend tests
echo "Running frontend tests..."
yarn nx run-many --target=test:front --nx-ignore-cycles -- --runInBand --coverage

echo "Tests completed successfully!"