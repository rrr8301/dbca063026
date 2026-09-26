#!/usr/bin/env bash

set -e

echo "=== Running Build ==="
pnpm build

echo "=== Running Tests ==="
pnpm test || {
  echo "FINAL_STATUS = FAIL"
  exit 1
}

echo "=== Running Typecheck ==="
pnpm typecheck || {
  echo "FINAL_STATUS = FAIL"
  exit 1
}

echo "FINAL_STATUS = SUCCESS"
