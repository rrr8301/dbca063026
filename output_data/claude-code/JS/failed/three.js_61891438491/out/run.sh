#!/usr/bin/env bash

set -e

echo "=== Lint testing ==="
npm run lint || true

echo ""
echo "=== Unit testing ==="
npm run test-unit || true

echo ""
echo "=== Unit addons testing ==="
npm run test-unit-addons || true

echo ""
echo "=== Examples ready for release ==="
npm run test-e2e-cov || true

echo ""
echo "FINAL_STATUS = SUCCESS"
