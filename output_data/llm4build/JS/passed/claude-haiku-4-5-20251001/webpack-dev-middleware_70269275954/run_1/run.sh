#!/bin/bash

set -e

# Run tests with coverage
npm run test:coverage -- --ci

echo "All tests completed successfully!"