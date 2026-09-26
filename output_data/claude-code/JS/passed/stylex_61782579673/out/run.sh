#!/usr/bin/env bash
set -e

cd /app

echo "Running: yarn test:packages"
yarn test:packages

echo "FINAL_STATUS = SUCCESS"
