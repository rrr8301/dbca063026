#!/bin/bash

# Activate any necessary environments (none specified)

# Install project dependencies
npm install

# Run tests
npm run tests-only || true

# Ensure all tests are executed, even if some fail
exit 0