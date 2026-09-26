#!/bin/bash

set -e

# Source nvm (should already be sourced by login shell, but ensure it)
export NVM_DIR=/root/.nvm
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"

# Use Node.js 11.15 (already installed as default)
nvm use 11.15

# Verify Node.js and npm installation
echo "node@$(node -v)"
echo "npm@$(npm -v)"

# Install mocha@8.4.0
npm install --save-dev mocha@8.4.0

# Install project dependencies
npm install

# List environment
echo "=== Environment ==="
npm -s ls ||:
(npm -s ls --depth=0 ||:) | awk -F'[ @]' 'NR>1 && $2 { print $2 "=" $3 }'

# Run linting
echo "=== Running Lint ==="
npm run lint || LINT_FAILED=1

# Run tests
echo "=== Running Tests ==="
if npm -ps ls nyc | grep -q nyc; then
    npm run test-ci || TEST_FAILED=1
else
    npm test || TEST_FAILED=1
fi

# Report results
echo "=== Test Summary ==="
if [ "$LINT_FAILED" = "1" ] || [ "$TEST_FAILED" = "1" ]; then
    echo "Some tests or linting checks failed"
    exit 1
fi

echo "All tests passed!"
exit 0