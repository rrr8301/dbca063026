#!/bin/bash

set -e

# Navigate to workspace
cd /workspace

# Install dependencies with TypeScript 4 (force to allow peer dependency conflicts)
npm install -D typescript@4 --force
npm install --ignore-scripts

# Install older cssnano for Node 14/16 compatibility
npm install -D --no-save cssnano@^6 --force

# Run tests with coverage and CI flag
npm run test:coverage -- --ci --passWithNoTests

echo "All tests completed successfully!"