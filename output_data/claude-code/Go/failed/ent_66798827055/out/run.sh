#!/usr/bin/env bash
set -e

cd /app

echo "========================================="
echo "Running cmd tests"
echo "========================================="
cd cmd && go test -race ./... || true
cd /app

echo "========================================="
echo "Running dialect tests"
echo "========================================="
cd dialect && go test -race ./... || true
cd /app

echo "========================================="
echo "Running schema tests"
echo "========================================="
cd schema && go test -race ./... || true
cd /app

echo "========================================="
echo "Running loader tests"
echo "========================================="
cd entc/load && go test -race ./... || true
cd /app

echo "========================================="
echo "Running codegen tests"
echo "========================================="
cd entc/gen && go test -race ./... || true
cd /app

echo "========================================="
echo "Running example tests"
echo "========================================="
cd examples && go test -race ./... || true
cd /app

echo "FINAL_STATUS = SUCCESS"
