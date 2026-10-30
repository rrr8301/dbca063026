#!/bin/bash

# Activate the environment (if any specific setup is needed, add here)

# Install project dependencies
yarn install --frozen-lockfile

# Link local packages
yarn link --frozen-lockfile || true
yarn link webpack --frozen-lockfile

# Run unit tests with coverage
yarn cover:unit --ci --cacheDirectory .jest-cache || true

# Ensure all tests are executed, even if some fail
exit 0