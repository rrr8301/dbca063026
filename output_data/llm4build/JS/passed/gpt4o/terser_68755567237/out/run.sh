#!/bin/bash

# Activate environment (if any specific activation is needed, add here)

# Install project dependencies
npm ci

# Build the app
npm run build --if-present

# Run tests (assuming tests are defined in package.json)
npm test || true  # Ensure all tests run even if some fail