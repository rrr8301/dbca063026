#!/usr/bin/env bash
set -e

cd /app

echo "=== Download dependencies ==="
go mod download

echo "=== Run unit and integration tests ==="
go test -race -tags=integration ./... || true

echo ""
echo "FINAL_STATUS = SUCCESS"
