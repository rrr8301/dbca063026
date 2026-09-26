#!/usr/bin/env bash
set -e

cd /app

# Set environment variables from the workflow
export TSGO_HEREBY_RACE=false
export TSGO_HEREBY_NOEMBED=false
export TSGO_HEREBY_CONCURRENT_TEST_PROGRAMS=false
export TSGO_HEREBY_COVERAGE=true

# Run all test tasks from the job
echo "=== Running tests ==="
npx hereby test

echo "=== Running benchmarks ==="
npx hereby test:benchmarks

echo "=== Running tools tests ==="
npx hereby test:tools

echo "=== Running API tests ==="
npx hereby test:api

echo "=== Stage changes ==="
git add .

echo "=== Check for staged changes ==="
git diff --staged --exit-code --stat

echo "=== All tests passed ==="
echo "FINAL_STATUS = SUCCESS"
