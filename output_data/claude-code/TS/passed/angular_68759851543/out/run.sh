#!/usr/bin/env bash

set -e

cd /app

echo "Running Angular test:ci..."
pnpm test:ci 2>&1

echo ""
echo "========================================="
echo "FINAL_STATUS = SUCCESS"
echo "========================================="
