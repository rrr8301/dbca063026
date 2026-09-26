#!/bin/bash

set -e

# Ensure hereby is installed
npm install -g hereby

# Function to run tests and handle errors
run_test() {
  local test_command=$1
  local test_name=$2

  echo "Running $test_name..."
  if ! npx hereby $test_command; then
    echo "$test_name failed"
    exit 1
  fi
}

# Run tests
run_test "test" "Test"
run_test "test:benchmarks" "Benchmark tests"
run_test "test:tools" "Tools tests"
run_test "test:api" "API tests"

# Check for uncommitted changes
git add .
if ! git diff --staged --exit-code --stat; then
  echo "There are uncommitted changes"
  exit 1
fi