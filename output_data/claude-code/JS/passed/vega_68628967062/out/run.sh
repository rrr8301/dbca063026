#!/usr/bin/env bash

set -e

echo "Running tests..."
npm run test:no-lint

echo "Running typecheck..."
npm run typecheck

echo "Running lint..."
npm run lint

echo "FINAL_STATUS = SUCCESS"
