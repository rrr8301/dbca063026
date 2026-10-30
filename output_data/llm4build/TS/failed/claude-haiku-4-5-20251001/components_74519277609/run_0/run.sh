#!/bin/bash

set -e

# Navigate to workspace
cd /workspace

# Read Node version from .nvmrc if it exists
if [ -f "components/.nvmrc" ]; then
    NODE_VERSION=$(cat components/.nvmrc | tr -d '\n' | tr -d ' ')
    echo "Installing Node.js version: $NODE_VERSION"
    
    # Install nvm and use specified Node version
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.0/install.sh | bash
    export NVM_DIR="$HOME/.nvm"
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
    nvm install "$NODE_VERSION"
    nvm use "$NODE_VERSION"
else
    echo "No .nvmrc found, using system Node.js"
fi

# Verify Node and npm versions
node --version
npm --version
pnpm --version

# Install node modules with frozen lockfile
echo "Installing node modules..."
pnpm install --frozen-lockfile

# Run Bazel tests
echo "Running Bazel tests..."
bazel test --build_tests_only --test_tag_filters=-linker-integration-test --test_tag_filters=-e2e -- //... -//goldens/... -//integration/...

echo "Tests completed successfully!"