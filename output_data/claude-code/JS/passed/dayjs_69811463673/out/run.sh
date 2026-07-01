#!/usr/bin/env bash

set -e

echo "Running linting..."
npm run lint

echo "Running tests..."
npm test

echo "FINAL_STATUS = SUCCESS"
