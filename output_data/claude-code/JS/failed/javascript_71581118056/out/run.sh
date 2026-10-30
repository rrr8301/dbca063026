#!/usr/bin/env bash
set -e

cd /app/packages/eslint-config-airbnb-base

echo "=== Node version ==="
node --version

echo "=== NPM version ==="
npm --version

echo "=== ESLint version ==="
node -pe "require('eslint/package.json').version"

echo "=== Running tests ==="
npm run travis

echo "FINAL_STATUS = SUCCESS"
