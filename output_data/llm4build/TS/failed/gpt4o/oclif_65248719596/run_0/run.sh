#!/bin/bash

# Simulate Git configuration
git config --global user.name "placeholder-username"
git config --global user.email "placeholder-email@example.com"

# Build the project
yarn build

# Run integration tests
set +e  # Continue executing even if some tests fail
yarn test:integration:cli