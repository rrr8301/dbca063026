#!/bin/bash

set -e

# Read Node version from .nvmrc
NODE_VERSION=$(cat .nvmrc)
echo "Using Node.js version: $NODE_VERSION"

# Install dependencies (1st npm ci)
echo "Installing dependencies (1)..."
PLAYWRIGHT_SKIP_BROWSER_DOWNLOAD=1 ELECTRON_SKIP_BINARY_DOWNLOAD=1 npm ci

# Download Playwright browsers with dependencies
echo "Downloading Playwright..."
npx playwright install --with-deps

# Install webpack plugin dependencies (2nd npm ci)
echo "Installing webpack plugin dependencies..."
npm ci --prefix webpack-plugin

# Build project
echo "Building project..."
npm run build

# Run unit tests
echo "Running unit tests..."
npm test

# Compile webpack plugin
echo "Compiling webpack plugin..."
npm run compile --prefix webpack-plugin

# Package using webpack plugin
echo "Packaging for smoketest..."
npm run package-for-smoketest

# Run smoke tests
echo "Running smoke tests..."
npm run smoketest

# Install website node modules
echo "Installing website dependencies..."
npm ci --prefix website

# Install most recent version of monaco-editor
echo "Installing monaco-editor..."
npm install --prefix website monaco-editor

# Build website
echo "Building website..."
npm run build --prefix website

# Test website
echo "Testing website..."
npm run test --prefix website

echo "All tests completed successfully!"