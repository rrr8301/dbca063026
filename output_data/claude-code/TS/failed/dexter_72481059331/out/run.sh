#!/usr/bin/env bash
set -e

echo "Running typecheck..."
bun run typecheck
echo "Typecheck completed."

echo ""
echo "Running tests..."
bun test
echo "Tests completed."

echo ""
echo "FINAL_STATUS = SUCCESS"
