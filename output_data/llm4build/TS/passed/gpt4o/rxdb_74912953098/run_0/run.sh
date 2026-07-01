#!/bin/bash

# Source nvm and use the correct Node.js version
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
nvm use

# Install project dependencies
npm install || (sleep 15 && npm install) || (sleep 15 && npm install)

# Build the project
npm run build

# Run tests
npm run test:typings
npm run test:react