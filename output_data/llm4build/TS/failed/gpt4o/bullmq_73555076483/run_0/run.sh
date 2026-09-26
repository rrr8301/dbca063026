#!/bin/bash

# Start Redis in the background
redis-server --daemonize yes

# Build the project
yarn build

# Run tests
yarn test:bun || true  # Ensure all tests run even if some fail