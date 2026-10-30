#!/bin/bash

set -e

# Set environment variables
export YARN_ENABLE_GLOBAL_CACHE=false
export SKIP_YARN_COREPACK_CHECK=1
export NOCK_ENV=replay

echo "=== Node.js and npm versions ==="
node --version
npm --version

echo "=== Corepack version ==="
corepack --version

echo "=== Installing dependencies with Yarn ==="
corepack yarn install --immutable

echo "=== Building project ==="
corepack yarn build

echo "=== Running tests ==="
corepack yarn test

echo "=== All tests completed ==="