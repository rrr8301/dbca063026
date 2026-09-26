#!/usr/bin/env bash
set -e

cd /app

echo "Running tests..."
corepack yarn test

echo "FINAL_STATUS = SUCCESS"
