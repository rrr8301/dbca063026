#!/bin/bash
set -e

# Activate nvm
export NVM_DIR=/opt/nvm
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"

# Install dependencies
npm install

# Run test sources
npm run test:sources

# Run test types
npm run test:types