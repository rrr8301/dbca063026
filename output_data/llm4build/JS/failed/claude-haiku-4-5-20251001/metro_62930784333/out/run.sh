#!/bin/bash
set -e

# Activate nvm
export NVM_DIR=/root/.nvm
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"

# Verify Node.js is available
node --version
npm --version
yarn --version

# Install project dependencies
# Using --no-lockfile as per nightly test configuration
yarn install --no-lockfile --non-interactive --ignore-scripts

# Run Jest tests with the exact command from the workflow
# Set the environment variable for nightly tests
export NIGHTLY_TESTS_NO_LOCKFILE=true

yarn jest --ci --maxWorkers 4 --reporters=default --reporters=jest-junit --rootdir='./'