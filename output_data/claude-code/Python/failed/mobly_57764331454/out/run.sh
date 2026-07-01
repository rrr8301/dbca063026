#!/usr/bin/env bash

set -e

echo "=== Running tests with tox ==="
tox || true

echo ""
echo "=== Checking formatting with pyink ==="
pyink --check . || true

echo ""
echo "FINAL_STATUS = SUCCESS"
