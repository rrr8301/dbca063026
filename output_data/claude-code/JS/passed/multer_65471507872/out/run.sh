#!/usr/bin/env bash

set -e

echo "Running lint..."
npm run lint

echo "Running tests..."
if npm -ps ls nyc | grep -q nyc; then
  npm run test-ci
else
  npm test
fi

echo "FINAL_STATUS = SUCCESS"
