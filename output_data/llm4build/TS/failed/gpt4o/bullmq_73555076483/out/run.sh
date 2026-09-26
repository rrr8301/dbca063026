#!/bin/bash

# Start Redis in the background
redis-server --daemonize yes

# Build the project
yarn build

# Run tests
yarn test:bun  # Ensure all tests run