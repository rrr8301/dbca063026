#!/usr/bin/env bash

set -e

cd /app

echo "Running Lint..."
npm run lint

echo "Running Tests..."
npm test

echo "FINAL_STATUS = SUCCESS"
