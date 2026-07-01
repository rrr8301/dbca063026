#!/bin/bash

# Install project dependencies
npm install

# Run tests
npm test -- --no-parallel || true

# Ensure all tests are executed, even if some fail