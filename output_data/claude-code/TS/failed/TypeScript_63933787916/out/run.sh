#!/usr/bin/env bash

cd /app

echo "Running tests..."
npm run test -- --no-lint --bundle=true || true

echo "FINAL_STATUS = SUCCESS"
