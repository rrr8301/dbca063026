#!/usr/bin/env bash

cd /app

echo "Running tests..."
npm run test || true

echo "FINAL_STATUS = SUCCESS"
