#!/usr/bin/env bash

set -e

echo "=== Environment ==="
echo "node: $(node -v)"
echo "npm: $(npm -v)"

echo ""
echo "=== List dependencies ==="
npm -s ls || true

echo ""
echo "=== Lint code ==="
npm run lint

echo ""
echo "=== Run tests ==="
if npm -ps ls nyc | grep -q nyc; then
  npm run test-ci
else
  npm test
fi

echo ""
echo "FINAL_STATUS = SUCCESS"
