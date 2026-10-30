#!/bin/bash

# Activate nvm
export NVM_DIR="/usr/local/nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"

# Run lint
npm run lint

# Run tests
npm test