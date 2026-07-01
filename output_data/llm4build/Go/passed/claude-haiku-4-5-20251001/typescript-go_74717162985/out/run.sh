#!/bin/bash

set -e

# Verify Go installation
echo "Go version:"
go version

# Verify Node.js installation
echo "Node.js version:"
node --version
echo "npm version:"
npm --version

# Install npm dependencies
echo "Installing npm dependencies..."
npm ci

# Install gotestsum
echo "Installing gotestsum..."
go install gotest.tools/gotestsum@latest

# Run tests
echo "Running tests..."
npx hereby test

echo "Running benchmarks..."
npx hereby test:benchmarks

echo "Running tools tests..."
npx hereby test:tools

echo "Running API tests..."
npx hereby test:api

# Stage changes (for coverage files)
echo "Staging changes..."
git add .

# Check for unstaged changes
echo "Checking for unstaged changes..."
git diff --staged --exit-code --stat

echo "All tests completed successfully!"