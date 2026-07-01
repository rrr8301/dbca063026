#!/usr/bin/env bash
set -e

# Install dependencies
npm ci

# Build the app
npm run build --if-present

# Run compress tests
npm run test:compress

# Run mocha tests
export TERSER_TEST_ALL=1
npm run test:mocha

# If we got here, tests ran successfully
echo "FINAL_STATUS = SUCCESS"
