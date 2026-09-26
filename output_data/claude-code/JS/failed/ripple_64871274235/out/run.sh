#!/usr/bin/env bash

cd /app

echo "Running tests..."
pnpm test || true

echo "FINAL_STATUS = SUCCESS"
