#!/usr/bin/env bash
set -e

cd /app

npm run test

FINAL_STATUS=SUCCESS
echo "FINAL_STATUS=$FINAL_STATUS"
