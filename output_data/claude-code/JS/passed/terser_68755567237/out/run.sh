#!/usr/bin/env bash
set -e

echo "Building the app..."
npm run build --if-present

echo "Running compress tests..."
npm run test:compress

echo "Running mocha tests..."
export TERSER_TEST_ALL=1
npm run test:mocha

echo ""
echo "FINAL_STATUS = SUCCESS"
