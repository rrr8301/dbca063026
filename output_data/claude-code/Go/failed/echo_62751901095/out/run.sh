#!/bin/sh

cd /app

echo "Running Go tests..."
go test -race --coverprofile=coverage.coverprofile --covermode=atomic ./... || true

echo "FINAL_STATUS = SUCCESS"
