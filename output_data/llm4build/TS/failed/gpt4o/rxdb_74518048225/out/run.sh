#!/bin/bash

# Source nvm to use Node.js
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"

# Use the Node.js version specified in .nvmrc
nvm use

# Run tests
npm run test:replication-google-drive