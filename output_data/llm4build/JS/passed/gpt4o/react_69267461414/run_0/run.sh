#!/bin/bash

# Activate environment (if any specific activation is needed, e.g., nvm)
# Assuming .nvmrc is used to specify Node.js version, but node:lts should cover it

# Ensure clean build directory
rm -rf build

# Install project dependencies if not cached
yarn install --frozen-lockfile
yarn --cwd compiler install --frozen-lockfile

# Run tests
set +e  # Continue executing even if some tests fail
yarn test -r=stable --env=development --ci --shard=3/5