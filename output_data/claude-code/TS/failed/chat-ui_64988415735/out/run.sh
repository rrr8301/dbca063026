#!/usr/bin/env bash
set -e

cd /app

echo "Running lint checks..."
npm run lint

echo "Running type checks..."
npm run check

echo ""
echo "FINAL_STATUS = SUCCESS"
