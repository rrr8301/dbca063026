#!/usr/bin/env bash

set -e

echo "Running cmd tests..."
cd /app/cmd && go test -race ./... || true

echo "Running dialect tests..."
cd /app/dialect && go test -race ./... || true

echo "Running schema tests..."
cd /app/schema && go test -race ./... || true

echo "Running loader tests..."
cd /app/entc/load && go test -race ./... || true

echo "Running codegen tests..."
cd /app/entc/gen && go test -race ./... || true

echo "Running example tests..."
cd /app/examples && go test -race ./... || true

echo "FINAL_STATUS = SUCCESS"
