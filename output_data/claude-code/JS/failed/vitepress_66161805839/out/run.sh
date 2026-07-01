#!/usr/bin/env bash
set -e

cd /app

echo "Running pnpm check..."
pnpm check

echo "FINAL_STATUS = SUCCESS"
