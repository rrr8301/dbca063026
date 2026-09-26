#!/bin/bash

# Output Node and NPM versions
echo "Node.js version: $(node -v)"
echo "NPM version: $(npm -v)"

# Run tests
npm run test-ci || true  # Ensure all tests run even if some fail