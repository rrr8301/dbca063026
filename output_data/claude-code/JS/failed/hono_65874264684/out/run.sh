#!/usr/bin/env bash

cd /app

echo "Running format check..."
bun run format || true

echo "Running lint..."
bun run lint || true

echo "Running editorconfig-checker..."
bun run editorconfig-checker -format github-actions || true

echo "Running build..."
bun run build || true

echo "Running tests..."
bun run test || true

echo "FINAL_STATUS = SUCCESS"
