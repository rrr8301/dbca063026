#!/usr/bin/env bash

set -e

cd /app

echo "=== Verify Code Generation ==="
make verify-generate
echo "verify-generate: OK"

echo ""
echo "=== Lint ==="
make lint
echo "lint: OK"

echo ""
echo "=== Build ==="
make build
echo "build: OK"

echo ""
echo "=== Test ==="
COVER=true make test
echo "test: OK"

echo ""
echo "FINAL_STATUS = SUCCESS"
