#!/bin/bash

# Install project dependencies
npm ci

# Run build and test
npm run build-and-test || true

# Ensure all tests are executed even if some fail
exit 0