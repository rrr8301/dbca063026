#!/bin/bash

# Activate nvm and use Node.js 20.9
source ~/.nvm/nvm.sh
nvm use 20.9

# Install project dependencies
npm install

# Lint the code
npm run lint

# Run tests
if npm -ps ls nyc | grep -q nyc; then
  npm run test-ci || true
else
  npm test || true
fi

# Ensure all tests are executed, even if some fail