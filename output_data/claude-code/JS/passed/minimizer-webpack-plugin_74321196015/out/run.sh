#!/usr/bin/env bash
set -e

cd /app

npm run test:coverage -- --ci

echo "FINAL_STATUS = SUCCESS"
