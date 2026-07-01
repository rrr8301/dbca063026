#!/bin/bash

# Install project dependencies
npm ci

# Lint code
npm run lint

# Run all tests
CI=true npm test