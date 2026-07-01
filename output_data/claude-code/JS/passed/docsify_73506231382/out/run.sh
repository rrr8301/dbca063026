#!/usr/bin/env bash
set -e

echo "Running Build..."
npm run build

echo "Running Unit Tests..."
npm run test:unit -- --ci --runInBand

echo "Running Integration Tests..."
npm run test:integration -- --ci --runInBand

echo "Running Consumption Tests..."
npm run test:consume-types

echo "FINAL_STATUS = SUCCESS"
