#!/bin/bash

# Set environment variables
export FORCE_COLOR=1
export NODE_VERSION=22.18.0
export DB=sqlite3
export NODE_ENV=testing

# Build TypeScript packages
yarn nx run-many -t build --exclude=ghost-admin

# Set environment variables for SQLite
echo "database__connection__filename=/dev/shm/ghost-test.db" >> $GITHUB_ENV

# Run E2E tests
cd ghost/core
yarn test:ci:e2e

# Run Integration tests
yarn test:ci:integration