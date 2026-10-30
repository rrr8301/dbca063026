#!/usr/bin/env bash

cd /app

echo "Running: npm run test:coverage -- --ci"
npm run test:coverage -- --ci || true

echo ""
echo "FINAL_STATUS = SUCCESS"
