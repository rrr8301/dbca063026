#!/bin/bash

# Activate environment (if any specific activation is needed, add here)

# Run tests
yarn test-ci --minWorkers=1 --maxWorkers=$(nproc)

# Ensure all tests are executed
set +e
yarn test-ci --minWorkers=1 --maxWorkers=$(nproc)
set -e