#!/bin/bash

set -e

# Verify that package.json exists
if [ ! -f "package.json" ]; then
    echo "Error: package.json not found in /workspace"
    exit 1
fi

# Install dependencies using npm ci (clean install)
echo "Installing dependencies..."
npm ci

# Find the actual Chromium binary path
CHROMIUM_BIN=$(which chromium-browser || which chromium || echo "/usr/bin/chromium-browser")

if [ ! -f "$CHROMIUM_BIN" ]; then
    echo "Error: Chromium binary not found at $CHROMIUM_BIN"
    exit 1
fi

echo "Using Chromium binary at: $CHROMIUM_BIN"

# Set Chromium executable path for headless testing
export CHROMIUM_BIN="$CHROMIUM_BIN"

# Set additional flags for headless Chrome in Docker
export PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true
export CHROME_BIN="$CHROMIUM_BIN"

# Run the test:selector-native test script
echo "Running test:selector-native..."
npm run test:selector-native -- --no-sandbox

echo "Tests completed successfully!"