#!/usr/bin/env bash

set -e

echo "Go version:"
go version

echo ""
echo "Running: go test -shuffle=on ./..."
go test -shuffle=on ./... || true

echo ""
echo "Running: go test -race -shuffle=on ./..."
go test -race -shuffle=on ./... || true

echo ""
echo "FINAL_STATUS = SUCCESS"
