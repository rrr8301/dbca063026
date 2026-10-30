#!/usr/bin/env bash
set -e

echo "=== Running npm run lint ==="
npm run lint

echo ""
echo "=== Running npm test ==="
CI=true npm test

echo ""
echo "=== Running npm run build ==="
npm run build

echo ""
echo "FINAL_STATUS = SUCCESS"
