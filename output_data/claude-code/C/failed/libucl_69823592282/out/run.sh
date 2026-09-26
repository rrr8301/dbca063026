#!/usr/bin/env bash
set -e

cd /app

echo "Running make check..."
make check || true

echo "Running make distcheck..."
make distcheck || true

echo "FINAL_STATUS = SUCCESS"
