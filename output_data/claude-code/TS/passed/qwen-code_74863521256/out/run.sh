#!/usr/bin/env bash
set -e

export NO_COLOR=true
export VITEST_POOL_THREADS_MIN=2
export VITEST_POOL_THREADS_MAX=4

echo "Starting tests..."
npm run test:ci || { echo "FINAL_STATUS = FAIL"; exit 1; }

echo "FINAL_STATUS = SUCCESS"
