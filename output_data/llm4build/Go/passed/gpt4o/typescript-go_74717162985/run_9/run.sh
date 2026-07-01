#!/bin/bash

# Ensure hereby is installed
npm install -g hereby

# Run tests
npx hereby test || { echo "Test failed"; exit 1; }
npx hereby test:benchmarks || { echo "Benchmark tests failed"; exit 1; }
npx hereby test:tools || { echo "Tools tests failed"; exit 1; }
npx hereby test:api || { echo "API tests failed"; exit 1; }

# Check for uncommitted changes
git add .
git diff --staged --exit-code --stat