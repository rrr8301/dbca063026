#!/usr/bin/env bash
set -e

export CGO_ENABLED=1
export GOARCH=amd64

echo "=== Starting fq test-race ==="
echo "Go version: $(go version)"
echo "Architecture: $GOARCH"
echo "CGO enabled: $CGO_ENABLED"
echo ""

cd /app
make test-race

echo ""
echo "FINAL_STATUS = SUCCESS"
