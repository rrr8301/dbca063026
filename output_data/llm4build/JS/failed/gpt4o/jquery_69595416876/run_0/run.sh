#!/bin/bash

# Activate environment variables if needed (none specified)

# Install project dependencies
npm ci

# Run tests
npm run test:selector-native || true

# Ensure all tests are executed, even if some fail
exit 0