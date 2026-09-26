#!/usr/bin/env bash
set -e

cd /app

echo "=== Running npm test ==="
npm run test

echo ""
echo "=== Running npm check-style ==="
npm run check-style

echo ""
echo "FINAL_STATUS = SUCCESS"
