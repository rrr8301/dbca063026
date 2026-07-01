#!/bin/bash

set -e

# Enable CI mode
export CI=true

echo "=== Node.js and npm versions ==="
node --version
npm --version

echo ""
echo "=== Installing dependencies ==="
npm install

echo ""
echo "=== Running tests ==="
npm test -- --no-parallel

echo ""
echo "=== Tests completed ==="