#!/bin/bash

set -e

# Ensure nvm is loaded
export NVM_DIR=$HOME/.nvm
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"

# Run tests with coverage
npm run test:coverage -- --ci

echo "All tests completed successfully!"