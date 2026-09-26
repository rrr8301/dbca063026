#!/bin/bash

set -e

# Source nvm
export NVM_DIR=/root/.nvm
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"

# Use Node.js 20.9
nvm use 20.9

# Print environment info
echo "node@$(node -v)"
echo "npm@$(npm -v)"

# Install npm dependencies
echo "Installing npm dependencies..."
npm install

# List dependencies
echo "Listing dependencies..."
npm -s ls ||:
(npm -s ls --depth=0 ||:) | awk -F'[ @]' 'NR>1 && $2 { print $2 "=" $3 }'

# Lint code
echo "Running linter..."
npm run lint || LINT_FAILED=1

# Run tests
echo "Running tests..."
if npm -ps ls nyc | grep -q nyc; then
  echo "nyc found, running test-ci..."
  npm run test-ci || TEST_FAILED=1
else
  echo "nyc not found, running test..."
  npm test || TEST_FAILED=1
fi

# Report results
if [ "$LINT_FAILED" = "1" ]; then
  echo "Linting failed!"
  exit 1
fi

if [ "$TEST_FAILED" = "1" ]; then
  echo "Tests failed!"
  exit 1
fi

echo "All checks passed!"
exit 0