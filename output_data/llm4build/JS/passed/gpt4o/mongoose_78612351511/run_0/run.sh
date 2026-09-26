#!/bin/bash

# Activate environment variables
export MONGOMS_VERSION=6.0.15
export MONGOMS_PREFER_GLOBAL_PATH=1
export FORCE_COLOR=true

# Install project dependencies
npm install

# Run npm script to create separate require instance
npm run create-separate-require-instance

# Run tests
npm run test:ci