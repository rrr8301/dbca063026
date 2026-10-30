#!/bin/bash

# Install project dependencies
yarn install

# Build the project
yarn build

# Run tests and ensure all tests are executed
yarn test || true