#!/bin/bash
set -e

# Read Node.js version from .nvmrc
if [ -f .nvmrc ]; then
    NODE_VERSION=$(cat .nvmrc | tr -d 'v')
    echo "Installing Node.js version: $NODE_VERSION"
    
    # Install nvm and the specified Node.js version
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.0/install.sh | bash
    export NVM_DIR="$HOME/.nvm"
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
    nvm install "$NODE_VERSION"
    nvm use "$NODE_VERSION"
else
    echo "Warning: .nvmrc not found, using system Node.js"
fi

# Verify Node.js and npm installation
node --version
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