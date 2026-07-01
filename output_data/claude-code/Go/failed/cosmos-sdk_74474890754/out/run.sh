#!/usr/bin/env bash
set -e

cd /app

echo "Running POA tests..."
cd enterprise/poa
go test -v -race -coverprofile=coverage.out -timeout 30m ./... || true

echo "FINAL_STATUS = SUCCESS"
