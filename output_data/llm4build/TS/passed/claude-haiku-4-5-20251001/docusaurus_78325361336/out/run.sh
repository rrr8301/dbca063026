#!/bin/bash
set -e

# Navigate to workspace
cd /workspace

# Installation with retries (as per YAML)
echo "Installing dependencies..."
yarn install --frozen-lockfile || yarn install --frozen-lockfile || yarn install --frozen-lockfile

# Run tests
echo "Running tests..."
yarn test

# Remove Theme Internal Re-export
echo "Removing theme internal re-export..."
yarn workspace @docusaurus/theme-common removeThemeInternalReexport

# Docusaurus Build
echo "Building website..."
NODE_OPTIONS='--max-old-space-size=450' DOCUSAURUS_PERF_LOGGER='true' yarn build:website:fast --locale en --locale fr

# Docusaurus site CSS order
echo "Testing CSS order..."
yarn workspace website test:css-order

# TypeCheck website
echo "TypeChecking website..."
yarn workspace website typecheck

# TypeCheck website - min version - v6.0
echo "TypeChecking website with TypeScript 6.0..."
yarn add typescript@6.0 --exact -D -W --ignore-scripts
yarn workspace website typecheck

# TypeCheck website - max version - Latest
echo "TypeChecking website with latest TypeScript..."
yarn add typescript@latest --exact -D -W --ignore-scripts
yarn workspace website typecheck --project tsconfig.skipLibCheck.json

echo "All tests completed successfully!"