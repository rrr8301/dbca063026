#!/usr/bin/env bash
set -e

echo "Running pnpm check..."
pnpm check

echo ""
echo "FINAL_STATUS = SUCCESS"
