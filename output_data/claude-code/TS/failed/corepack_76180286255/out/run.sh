#!/usr/bin/env bash
set -e

cd /app

# Run tests
corepack yarn test

FINAL_STATUS=SUCCESS
echo "FINAL_STATUS = $FINAL_STATUS"
