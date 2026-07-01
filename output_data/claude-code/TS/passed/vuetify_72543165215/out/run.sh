#!/usr/bin/env bash
set -e

cd /app/packages/vuetify

echo "Running tests..."
pnpm run test

echo ""
echo "FINAL_STATUS = SUCCESS"
