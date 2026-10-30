#!/bin/bash

# Check if the test script exists in package.json
if npm run | grep -q "test:e2e-test"; then
  # Run tests
  npm run test:e2e-test
else
  echo "Error: Missing script 'test:e2e-test' in package.json"
  exit 1
fi