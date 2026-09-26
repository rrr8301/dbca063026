#!/bin/bash

# Set environment variables
export FORCE_COLOR=1
export NODE_VERSION=22.18.0  # Update to match the installed Node.js version
export DB=sqlite3
export NODE_ENV=testing

# Build TypeScript packages
yarn nx run-many -t build --exclude=ghost-admin

# Set environment variables for SQLite
echo "database__connection__filename=/dev/shm/ghost-test.db" >> $GITHUB_ENV

# Ensure SQLite database file exists
touch /dev/shm/ghost-test.db

# Run E2E tests
cd ghost/core
yarn test:ci:e2e || exit 1

# Run Integration tests
yarn test:ci:integration || exit 1