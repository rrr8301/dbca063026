#!/usr/bin/env bash

set -e

echo "===== Running Linting ====="
npm run lint
echo "Linting passed!"

echo ""
echo "===== Running Tests ====="
CI=true npm test
echo "Tests passed!"

echo ""
echo "===== Running Build ====="
npm run build
echo "Build completed!"

echo ""
echo "FINAL_STATUS = SUCCESS"
