#!/bin/bash

# Activate nvm and use Node.js 20.x
export NVM_DIR="/usr/local/nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
nvm use 20

# Build the project
npm run build

# Run tests
npm run test:ci