#!/bin/bash

# Exit immediately if a command exits with a non-zero status
set -e

# Run yarn link commands
yarn link --frozen-lockfile || true
yarn link webpack --frozen-lockfile

# Run tests
yarn test:basic --ci || true

# Ensure all tests are executed even if some fail
exit 0