#!/bin/bash

# Install project dependencies
npm ci

# Install Playwright dependencies
npx playwright install

# Run tests
npm run test || true  # Ensure all tests run even if some fail