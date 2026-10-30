#!/usr/bin/env bash
set -e

echo "Running test:sources..."
npm run test:sources
echo "test:sources completed"

echo "Running test:types..."
npm run test:types
echo "test:types completed"

echo "FINAL_STATUS = SUCCESS"
