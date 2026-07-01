#!/usr/bin/env bash
set -e

echo "Running npm run test-node:unit..."
npm run test-node:unit

echo ""
echo "Generating coverage report..."
npm run test-coverage-generate

echo ""
echo "FINAL_STATUS = SUCCESS"
