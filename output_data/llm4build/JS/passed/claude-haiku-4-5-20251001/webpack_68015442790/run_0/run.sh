#!/bin/bash

set -e

# Change to workspace directory
cd /workspace

echo "Installing dependencies with frozen lockfile..."
yarn install --frozen-lockfile

echo "Linking yarn packages..."
yarn link --frozen-lockfile || true

echo "Linking webpack..."
yarn link webpack --frozen-lockfile

echo "Running unit tests with coverage..."
yarn cover:unit --ci --cacheDirectory .jest-cache

echo "Unit tests completed successfully!"