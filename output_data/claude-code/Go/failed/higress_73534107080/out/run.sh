#!/usr/bin/env bash
set -e

cd /app

echo "Go version:"
go version

echo ""
echo "Running coverage tests..."
GOPROXY="https://proxy.golang.org,direct" make go.test.coverage

echo ""
echo "FINAL_STATUS = SUCCESS"
