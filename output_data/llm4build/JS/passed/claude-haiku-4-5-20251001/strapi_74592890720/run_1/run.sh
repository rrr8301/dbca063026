#!/bin/bash

set -e

# Enable strict error handling
set -o pipefail

# Print commands for debugging
set -x

# Navigate to workspace
cd /workspace

# Configure git (required for Nx affected detection with fetch-depth: 0)
git config --global --add safe.directory /workspace

# Enable corepack
corepack enable

# Set environment variables for yarn install (from custom action)
export YARN_ENABLE_GLOBAL_CACHE='false'
export YARN_ENABLE_MIRROR='false'
export YARN_NM_MODE='hardlinks-local'
export YARN_INSTALL_STATE_PATH='.yarn/ci-cache/install-state.gz'

# Install dependencies (from .github/actions/yarn-nm-install)
echo "Installing dependencies..."
yarn install --immutable --inline-builds

# Build the monorepo (from .github/actions/run-build)
echo "Building monorepo..."
yarn nx run-many --targets build --nx-ignore-cycles --skip-nx-cache

# Run unit tests with coverage (using run-many instead of affected for Docker compatibility)
echo "Running unit tests..."
yarn nx run-many --target=test:unit --nx-ignore-cycles -- --coverage

echo "Tests completed successfully!"