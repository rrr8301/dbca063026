#!/bin/bash

# Activate nvm
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"

# Use the specified Node.js version
nvm use 20

# Install project dependencies
npm install --ignore-scripts

# Run unit tests
npm run unit