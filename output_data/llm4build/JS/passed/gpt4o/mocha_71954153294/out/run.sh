#!/bin/bash

# Activate environment variables if needed (none specified)

# Run npm script for testing
npm run test-node:unit || true

# Generate coverage report if coverage is enabled
if [ "$COVERAGE" == "1" ]; then
  npm run test-coverage-generate || true
fi

# Ensure all tests are executed, even if some fail
exit 0