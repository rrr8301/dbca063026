#!/bin/bash

# Load nvm and use the specified Node.js version
export NVM_DIR="/usr/local/nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
nvm use default

# Install project dependencies
npm ci

# Download Playwright dependencies
npx playwright install --with-deps

# Execute npm commands
npm run build
npm test
npm run compile --prefix webpack-plugin
npm run package-for-smoketest
npm run smoketest

# Install website dependencies and run tests
cd website
npm ci
npm install monaco-editor
npm run build
npm run test