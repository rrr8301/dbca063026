#!/bin/bash

set -e

# Source nvm
export NVM_DIR=/root/.nvm
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"

# Use Node.js 25.6.1 for yarn install
nvm use 25.6.1

echo "=== Installing dependencies with yarn ==="
yarn install

echo "=== Building babel-artifact (simulating prior build job) ==="
# Simulate the build job output by building the project
# This assumes the build job produces compiled packages
yarn build 2>/dev/null || echo "Build step not available or already built"

echo "=== Switching to Node.js 24 for testing ==="
nvm use 24

echo "=== Running node flags script ==="
node ./packages/babel-node/scripts/list-node-flags.js

echo "=== Running Jest tests on Node.js 24 ==="
export BABEL_ENV=test
export TEST_FUZZ=true

# Run jest with --ci flag, continue even if tests fail
node ./node_modules/.bin/jest --ci || TEST_EXIT_CODE=$?

# Exit with test result code if tests failed
if [ ! -z "$TEST_EXIT_CODE" ]; then
    exit $TEST_EXIT_CODE
fi

exit 0