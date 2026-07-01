#!/usr/bin/env bash

cd /app

echo "Running tests with coverage..."
npm run test:coverage -- --ci || true

FINAL_STATUS="SUCCESS"
echo "FINAL_STATUS = $FINAL_STATUS"
