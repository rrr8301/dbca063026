#!/bin/bash

# Activate environment (if any)

# Install project dependencies
npm install

# Run tests with coverage
mkdir -p ./superset-frontend/coverage
npm run test -- --coverage --shard=3/8 --coverageReporters=json

# Ensure all test cases are executed