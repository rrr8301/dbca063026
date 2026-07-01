#!/usr/bin/env bash
set -e

cd /app

echo "Running pnpm test..."
pnpm test

echo "FINAL_STATUS = SUCCESS"
