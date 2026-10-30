#!/usr/bin/env bash

set -e

echo "=== Running tests ==="
npm run test

echo "=== Running code style check ==="
npm run check-style

echo "FINAL_STATUS = SUCCESS"
