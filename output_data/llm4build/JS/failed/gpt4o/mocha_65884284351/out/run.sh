#!/bin/bash

# Activate environment variables if needed (none specified)

# Run npm script specified by the input
npm run test-node:integration

# Ensure all tests are executed, even if some fail
set +e
npm run test-node:integration
set -e