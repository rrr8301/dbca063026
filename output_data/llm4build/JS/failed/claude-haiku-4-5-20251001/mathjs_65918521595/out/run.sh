#!/bin/bash
set -e

# Navigate to repository root
cd /workspace

# Install dependencies using npm ci (clean install)
npm ci

# Run tests with CI environment variable
CI=true npm run test:src