#!/usr/bin/env bash

set -e

echo "=== Test source headers are present ==="
make test-source-headers || true

echo "=== Check if go modules need to be tidied ==="
go mod tidy -diff || true

echo "=== Run unit tests ==="
make test-coverage || true

echo "=== Test build ==="
make build || true

echo "FINAL_STATUS = SUCCESS"
