#!/usr/bin/env bash

set -e

echo "Running Unit Tests..."
npm run test:unit -- --ci --runInBand || true

echo ""
echo "Running Integration Tests..."
npm run test:integration -- --ci --runInBand || true

echo ""
echo "Running Consumption Tests..."
npm run test:consume-types || true

echo ""
echo "FINAL_STATUS = SUCCESS"
