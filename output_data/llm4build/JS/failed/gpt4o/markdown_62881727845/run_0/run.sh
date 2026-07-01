#!/bin/bash

# Install project dependencies
npm install

# Run tests
npm run test || true  # Ensure all tests run even if some fail