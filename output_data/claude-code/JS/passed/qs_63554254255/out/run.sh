#!/usr/bin/env bash
set -e

cd /app

npm run tests-only

echo "FINAL_STATUS = SUCCESS"
