#!/bin/bash

# Activate environment (if any specific activation is needed, add here)

# Install project dependencies
npm install

# Run tests
npm run tests-only || true

# Ensure all tests are executed, even if some fail
exit 0