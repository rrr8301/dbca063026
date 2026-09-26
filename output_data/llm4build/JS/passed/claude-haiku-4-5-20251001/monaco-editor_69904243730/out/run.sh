#!/bin/bash

set -e

# Read Node version from .nvmrc
NODE_VERSION=$(cat .nvmrc)
echo "Node version from .nvmrc: $NODE_VERSION"

# Verify Node.js is installed
node --version
npm --version

# Step 1: Install build tools (already done in Dockerfile, but ensure apt is up to date)
echo "Build tools already installed in Dockerfile"

# Step 2: Execute npm ci (1) with environment variables
echo "Running npm ci (1)..."
export PLAYWRIGHT_SKIP_BROWSER_DOWNLOAD=1
export ELECTRON_SKIP_BINARY_DOWNLOAD=1
npm ci

# Step 3: Download Playwright with dependencies
echo "Installing Playwright..."
npx playwright install --with-deps

# Step 4: Execute npm ci (2) for webpack-plugin
echo "Running npm ci (2) for webpack-plugin..."
npm ci --prefix webpack-plugin

# Step 5: Build
echo "Building..."
npm run build

# Step 6: Run unit tests
echo "Running unit tests..."
npm test

# Step 7: Compile webpack plugin
echo "Compiling webpack plugin..."
npm run compile --prefix webpack-plugin

# Step 8: Package using webpack plugin
echo "Packaging for smoketest..."
npm run package-for-smoketest

# Step 9: Run smoke test
echo "Running smoke test..."
npm run smoketest

# Step 10: Install website node modules
echo "Installing website node modules..."
cd website
npm ci

# Step 11: Install most recent version of monaco-editor
echo "Installing latest monaco-editor..."
npm install monaco-editor

# Step 12: Build website
echo "Building website..."
npm run build

# Step 13: Test website
echo "Testing website..."
npm run test

echo "All tests completed successfully!"