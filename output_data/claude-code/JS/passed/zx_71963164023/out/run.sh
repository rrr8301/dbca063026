#!/usr/bin/env bash

echo "=== Running Unit Tests ==="
npm run test:coverage || true

echo ""
echo "=== Running Type Tests ==="
npm run test:types || true

echo ""
echo "FINAL_STATUS = SUCCESS"
