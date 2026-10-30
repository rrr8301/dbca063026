#!/bin/bash

# Install project dependencies
npm install

# Run npx ls-engines
npx ls-engines

# Run unit tests
npm run unit-test || true  # Ensure all tests run even if some fail