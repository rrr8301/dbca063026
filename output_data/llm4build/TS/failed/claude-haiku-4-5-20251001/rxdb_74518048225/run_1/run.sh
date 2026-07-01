#!/bin/bash
set -e

# Read Node.js version from .nvmrc
if [ -f .nvmrc ]; then
    NODE_VERSION=$(cat .nvmrc | tr -d 'v')
    echo "Installing Node.js version: $NODE_VERSION"
    
    # Use n to install the specified Node.js version
    n "$NODE_VERSION"
else
    echo "Warning: .nvmrc not found, using system Node.js"
fi

# Verify Node.js and npm installation
echo "Node.js version:"
node --version
echo "npm version:"
npm --version

# Install dependencies with retries
echo "Installing npm dependencies..."
npm install || (sleep 15 && npm install) || (sleep 15 && npm install)

# Build the project
echo "Building RxDB core..."
npm run build

# Run replication tests
echo "Running replication tests..."
npm run test:replication-google-drive