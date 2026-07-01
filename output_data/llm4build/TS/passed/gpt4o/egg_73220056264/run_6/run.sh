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

# Check if the 'clean-dist' script exists in package.json before running
if pnpm run | grep -q 'clean-dist'; then
  pnpm run clean-dist || echo "Warning: 'clean-dist' script failed"
else
  echo "Warning: 'clean-dist' script not found in package.json"
fi

# Check if the 'pretest' script exists in package.json before running
if pnpm run | grep -q 'pretest'; then
  pnpm run pretest || echo "Warning: 'pretest' script failed"
else
  echo "Warning: 'pretest' script not found in package.json"
fi

# Run the CI script
if pnpm run | grep -q 'ci'; then
  pnpm run ci || echo "Warning: 'ci' script failed"
else
  echo "Warning: 'ci' script not found in package.json"
fi

set -e  # Stop execution on errors after tests