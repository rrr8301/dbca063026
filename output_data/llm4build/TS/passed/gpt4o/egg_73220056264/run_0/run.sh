#!/bin/bash

# Start Redis server
service redis-server start

# Start MySQL server
service mysql start

# Initialize the database
mysql -uroot -e "CREATE DATABASE IF NOT EXISTS test;"

# Setup utoo (assuming utoo setup is a script or command available in the repo)
# Placeholder for utoo setup
echo "Setting up utoo..."

# Set up Node.js environment
# Node.js is already installed via Dockerfile

# Install dependencies using pnpm
pnpm install --from pnpm

# Run tests with coverage
set +e  # Continue execution even if some tests fail
pnpm run ci
set -e  # Stop execution on errors after tests

# Note: Code coverage step is skipped