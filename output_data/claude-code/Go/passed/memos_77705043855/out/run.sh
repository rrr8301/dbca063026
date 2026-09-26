#!/usr/bin/env bash
set -e

export DRIVER=sqlite

echo "Running server tests..."
go test -v -race -coverprofile=coverage.out -covermode=atomic ./server/...

echo ""
echo "FINAL_STATUS = SUCCESS"
