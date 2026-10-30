#!/bin/bash

# Install project dependencies
corepack yarn install --immutable

# Build the project
corepack yarn build

# Run tests
corepack yarn test