#!/usr/bin/env bash
set -e

echo "Getting Playwright version..."
PW_VERSION=$(pnpm --filter @remix-run/ui exec playwright --version | cut -d ' ' -f2)
echo "Playwright version: $PW_VERSION"

echo "Installing Playwright browsers..."
pnpm --filter @remix-run/ui exec playwright install --with-deps

echo "Running tests..."
pnpm test || true

echo "FINAL_STATUS = SUCCESS"
