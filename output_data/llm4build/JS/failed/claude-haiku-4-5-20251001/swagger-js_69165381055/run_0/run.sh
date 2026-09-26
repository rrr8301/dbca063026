#!/bin/bash
set -e

# Install dependencies
npm ci

# Run linting (continue on failure to run all tests)
npm run lint || true

# Run tests with CI environment variable
CI=true npm test