#!/usr/bin/env bash
set -e

cd /app

echo "Running tests with coverage..."
pnpm vitest --coverage

echo "FINAL_STATUS = SUCCESS"
