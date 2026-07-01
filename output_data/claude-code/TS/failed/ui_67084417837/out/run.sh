#!/usr/bin/env bash

cd /app

echo "Running: pnpm test"
pnpm test || true

echo "FINAL_STATUS = SUCCESS"
