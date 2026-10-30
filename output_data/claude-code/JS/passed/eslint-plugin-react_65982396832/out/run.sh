#!/usr/bin/env bash

set -e

echo "Running ls-engines..."
npx ls-engines

echo ""
echo "Running unit tests..."
npm run unit-test

echo ""
echo "FINAL_STATUS = SUCCESS"
