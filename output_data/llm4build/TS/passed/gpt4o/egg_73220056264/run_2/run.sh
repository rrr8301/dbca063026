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
pnpm install

# Run tests with coverage
set +e  # Continue execution even if some tests fail

# Check if the 'clean' script exists in package.json before running
if pnpm run | grep -q 'clean'; then
  pnpm run clean
else
  echo "Warning: 'clean' script not found in package.json"
fi

# Check if the 'pretest' script exists in package.json before running
if pnpm run | grep -q 'pretest'; then
  pnpm run pretest
else
  echo "Warning: 'pretest' script not found in package.json"
fi

# Run the CI script
pnpm run ci

set -e  # Stop execution on errors after tests