#!/usr/bin/env bash

set -e

cd /app

echo "Running unit tests..."
yarn test --maxWorkers=2 --coverage

echo "FINAL_STATUS = SUCCESS"
