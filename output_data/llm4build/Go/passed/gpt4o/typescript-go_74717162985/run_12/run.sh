#!/bin/bash

# Ensure hereby is installed
npm install -g hereby

# Run tests
if ! npx hereby test; then
  echo "Test failed"
  exit 1
fi

if ! npx hereby test:benchmarks; then
  echo "Benchmark tests failed"
  exit 1
fi

if ! npx hereby test:tools; then
  echo "Tools tests failed"
  exit 1
fi

if ! npx hereby test:api; then
  echo "API tests failed"
  exit 1
fi

# Check for uncommitted changes
git add .
if ! git diff --staged --exit-code --stat; then
  echo "There are uncommitted changes"
  exit 1
fi