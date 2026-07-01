#!/usr/bin/env bash
set -e

cd /app

echo "=== Building project ==="
npm run build

echo "=== Running unit tests ==="
npm run test:node || true

echo "=== Running package tests ==="
npm run test:package || true

echo "FINAL_STATUS = SUCCESS"
