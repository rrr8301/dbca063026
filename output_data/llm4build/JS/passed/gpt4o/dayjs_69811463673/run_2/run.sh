#!/bin/bash

# Activate nvm
export NVM_DIR="/usr/local/nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"

# Add nvm to PATH
export PATH="$NVM_DIR/versions/node/$(nvm version)/bin:$PATH"

# Run lint
npm run lint

# Run tests
npm test