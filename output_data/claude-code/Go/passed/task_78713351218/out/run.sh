#!/usr/bin/env bash
set -e

cd /app

echo "Running: go run ./cmd/task test"
go run ./cmd/task test

FINAL_STATUS=SUCCESS
echo "FINAL_STATUS = $FINAL_STATUS"
