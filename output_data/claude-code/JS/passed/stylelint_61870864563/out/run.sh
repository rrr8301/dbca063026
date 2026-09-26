#!/usr/bin/env bash

set -e

echo "Node version: $(node --version)"
echo "npm version: $(npm --version)"

echo "Running tests..."
npm test --ignore-scripts

echo "FINAL_STATUS = SUCCESS"
