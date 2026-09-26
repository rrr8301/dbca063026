#!/bin/bash

# Activate nvm and use Node.js 22.x
export NVM_DIR="/usr/local/nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
nvm use 22

# Build the project
npm run build

# Run tests
npm run test:ci