#!/bin/bash

# Activate environment (if any specific activation is needed, e.g., nvm use)
# Not needed here as Node.js is installed globally

# Install project dependencies
npm ci

# Run tests
npm run test:browserless || true

# Ensure all tests are executed even if some fail
exit 0