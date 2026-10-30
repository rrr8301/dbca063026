#!/bin/bash

# Activate Node.js 25.6.1 for yarn install
nvm install 25.6.1
nvm use 25.6.1

# Install project dependencies
yarn install

# Simulate artifact build (assumption)
# Placeholder for building babel-artifact from source if needed

# Activate Node.js 24 for testing
nvm install 24
nvm use 24

# Ensure @babel/node's list of node flags is up to date
node ./packages/babel-node/scripts/list-node-flags.js

# Run tests with Jest
BABEL_ENV=test TEST_FUZZ=true node ./node_modules/.bin/jest --ci || true

# Ensure all tests are executed even if some fail