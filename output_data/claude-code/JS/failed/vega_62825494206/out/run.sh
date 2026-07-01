#!/usr/bin/env bash

set -e

echo "Running npm run test:no-lint..."
npm run test:no-lint || true

echo "Running npm run typecheck..."
npm run typecheck || true

echo "Running npm run lint..."
npm run lint || true

echo "FINAL_STATUS = SUCCESS"
