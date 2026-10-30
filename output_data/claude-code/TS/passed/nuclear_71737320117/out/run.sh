#!/usr/bin/env bash

set -e

cd /app

echo "Running lint..."
pnpm lint

echo "Running tests..."
pnpm test

echo "Building..."
pnpm build

echo "FINAL_STATUS = SUCCESS"
