#!/bin/bash

# Activate nvm
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"

# Use the Node.js version specified in .nvmrc
nvm use

# Install project dependencies
yarn install --immutable

# Run tests
set +e  # Continue execution even if some tests fail
yarn test --maxWorkers=2 --coverage
set -e  # Stop execution on errors after tests

# Note: Code coverage upload is skipped