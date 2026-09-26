#!/usr/bin/env bash

set -e

cd /app

echo "=== Running Lint testing ==="
npm run lint

echo "=== Running Unit testing ==="
npm run test-unit

echo "=== Running Unit addons testing ==="
npm run test-unit-addons

echo "=== Running Examples ready for release ==="
npm run test-e2e-cov

echo ""
echo "FINAL_STATUS = SUCCESS"
