#!/bin/bash
set -e

# Source nvm
export NVM_DIR=/root/.nvm
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"

# Use Node.js 25
nvm use 25

# Verify Node.js and npm versions
echo "Node.js version:"
node --version
echo "npm version:"
npm --version

# Install npm dependencies (including eslint, typescript-eslint, babel-eslint)
npm install --no-save "eslint@9" "@typescript-eslint/parser@8.17" "babel-eslint@8"

# Run ls-engines diagnostic
npx ls-engines

# Run unit tests
npm run unit-test