#!/bin/bash

# Load nvm
export NVM_DIR="/usr/local/nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"

# Use Node.js version 26
nvm use 26

# Run tests
yarn test

# Additional commands can be added here if needed