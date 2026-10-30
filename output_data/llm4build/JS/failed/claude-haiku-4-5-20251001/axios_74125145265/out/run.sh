#!/bin/sh
set -e

# Verify we're in the workspace directory
cd /workspace

# Install dependencies
npm ci --ignore-scripts

# Build project
npm run build

# Run tests
npm run test