#!/usr/bin/env bash
set -e

cd /app

echo "Running backend unit tests..."
if pnpm test:ci:backend:unit --summarize; then
    echo "FINAL_STATUS = SUCCESS"
else
    echo "FINAL_STATUS = FAIL"
    exit 1
fi
