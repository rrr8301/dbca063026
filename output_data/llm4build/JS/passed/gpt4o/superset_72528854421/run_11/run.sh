#!/bin/bash

# Ensure npm dependencies are installed
if [ -f package.json ]; then
  npm install
fi

# Run tests with coverage
mkdir -p ./superset-frontend/coverage
npm run test -- --coverage --shard=3/8 --coverageReporters=json