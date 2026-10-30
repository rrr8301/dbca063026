#!/bin/bash

# Activate environment variables
export MONGOMS_VERSION=7.0.12
export MONGOMS_PREFER_GLOBAL_PATH=1
export FORCE_COLOR=true

# Install project dependencies
npm install

# Run custom npm script
npm run create-separate-require-instance

# Run tests
npm run test:ci