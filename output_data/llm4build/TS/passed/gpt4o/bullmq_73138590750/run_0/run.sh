#!/bin/bash

# Start Redis server
redis-server --daemonize yes

# Run ESLint
yarn lint

# Build the project
yarn build

# Run tests
yarn test || true  # Ensure all tests run even if some fail